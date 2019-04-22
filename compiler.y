%defines

%code requires {
	/* C declarations and #DEFINE statement */
	#include <stdio.h>
	#include <cstring>
	#include "BasicBlock.hpp"
	#include "SymbolTable.hpp"
	#include <iostream>

	int yyerror(char const *errmsg);
	int yylex(void);
}

%code{	
	BasicBlock* block = new BasicBlock(0);
	SymbolTable symbolTable;
	int registerCount = 0;
	int getRegister(){
		registerCount++;
		return registerCount-1;
	}	
}
%union{
	int 	i_val;
	double 	f_val;
	char    c_val;
	bool	b_val;
	char 	*s_val;
	Operand *operand;
	Instruction::Opcode  opcode;
}

/* Bison token declaration */
%token INT FLOAT VOID CHAR BOOL
%token INT_VAL STR_VAL FLOAT_VAL ID TRUE FALSE CHAR_VAL
%token IF ELSE
%right ASSGN
%left  LO_OR
%left  LO_AND
%left  EQ NE
%left  LE GE LT GT
%left '+' '-'
%left '*' '/'
%token NEWLINE ';'

%type <i_val>  	INT_VAL
%type <f_val>  	FLOAT_VAL
%type <s_val>  	STR_VAL ID
%type <c_val>	CHAR_VAL
%type <b_val>	TRUE FALSE 
%type <operand>	factor term expr bool_base bool_expr bool_term
%type <opcode> compare

%% /* grammar rules */
input		: /* empty production for empty input */
			|	input line
			;
line		:	test_assign  NEWLINE
			|	expr  NEWLINE										
			|	func_def
			;
test_assign :	ID ASSGN expr ';'
			{
				cout << "dumpBasicBlock():\n"<< block -> dumpBasicBlock()<<endl;
			}
			;
func_def 	:	type ID '(' param_lists ')'  stmt_block NEWLINE 	{cout << "dumpBasicBlock():\n"<< block -> dumpBasicBlock()<<endl;}
			;
type 		:	INT
			|	FLOAT
			|	VOID
			|	BOOL
			;
param_lists : 
			|	params
			;	
params		: 	type ID ',' params
			|	type ID
			;
stmt_block 	:	'{' stmts '}'
			|	stmt
			;
stmts 		:	stmt stmts
			|
			;
stmt 		:	stmt_decl
			| 	stmt_assgn
			|	stmt_if
			|	';'
			;
stmt_decl 	:	INT ID ASSGN expr ';'		
			{ 
				if (!symbolTable.find($2)){
					// Create destination operand
					int registerNo = getRegister();
					Operand *dest = new Operand(Operand::REGISTER,registerNo, INT_T);

					// Create a Store instruction
					Instruction inst (Instruction::STORE, *dest, *$4);

					// Add instruction to current block
					block -> pushBackInstruction(inst);
					
					// Remove source operands
					delete $4;

					symbolTable.insert($2, registerNo, Node::VAR, Node::GLOBAL, INT_T, 0);

				} else {
					// The variable is already declared. Print errors
				}
			}
			
			|	FLOAT ID ASSGN expr ';'	{ 
				if (!symbolTable.find($2)){
					// Create destination operand
					int registerNo = getRegister();
					Operand *dest = new Operand(Operand::REGISTER,registerNo, FLOAT_T);

					// Create a store instruction
					Instruction inst (Instruction::STORE, *dest, *$4);

					// Add instruction to current block
					block -> pushBackInstruction(inst);
					
					// Remove source operands
					delete $4;

					symbolTable.insert($2, registerNo, Node::VAR, Node::GLOBAL, FLOAT_T, 0);
				} else {
					// The variable is already declared. Print errors
					string errmsg = "Variable is not declared!";
					yyerror(errmsg.c_str());
				}
			}
			;
stmt_assgn  :	ID ASSGN expr ';'
			{
				if (symbolTable.find($1)){
					// Variable is declared, we can assign new value.
					
					// Get the node for the variable
					Node temp = symbolTable.getNode($1);

					// Check to see correct type
					if (temp.getDataType() == $3->getDataType()){
						// Correct type. Update variable
						Operand *dest = new Operand(Operand::REGISTER,temp.getRegister(), temp.getDataType());

						// Create a store instruction
						Instruction inst (Instruction::STORE, *dest, *$3);

						// Add instruction to current block
						block -> pushBackInstruction(inst);
					} else {
						// Wrong type. Errors
						string errmgs = "The expr is not the same type as the ID.";
						yyerror(errmgs.c_str());
					}
				} else {
					// Variable is not declared. Print errors.
					string errmsg = "Variable is not declared!";
					yyerror(errmsg.c_str());
				}
			}
			;
stmt_if		: 	IF '(' bool_expr ')' stmt_block NEWLINE
			{

			}
			;
bool_expr	:	 bool_base LO_OR bool_term 
			{
				// Setting the type of Operand
				DataType type = BOOL_T;

				// Create destination operand
				Operand *dest = new Operand(Operand::REGISTER, getRegister(), type);

				// Store the first part into the register. This is so that data in $1 and $3 remain unchanged.
				Instruction inst (Instruction::STORE, *dest, *$3);

				// Add instruction to current block
				block -> pushBackInstruction(inst);
				
				// Doing the AND operation
				Instruction inst2 (Instruction::AND, *dest, *$1);
				block -> pushBackInstruction(inst2);

				// Remove source operands
				delete $1;
				delete $3;

				// Return destination operand
				$$ = dest;
			}
			|	 bool_base LO_AND bool_term 
			{
				// Setting the type of Operand
				DataType type = BOOL_T;

				// Create destination operand
				Operand *dest = new Operand(Operand::REGISTER, getRegister(), type);

				// Store the first part into the register. This is so that data in $1 and $3 remain unchanged.
				Instruction inst (Instruction::STORE, *dest, *$1);

				// Add instruction to current block
				block -> pushBackInstruction(inst);
				
				// Doing the AND operation
				Instruction inst2 (Instruction::OR, *dest, *$3);
				block -> pushBackInstruction(inst2);

				// Remove source operands
				delete $1;
				delete $3;

				// Return destination operand
				$$ = dest;
			}
			|	bool_base
			{
				$$ = $1;
			}
			;
bool_term	:	'('	bool_expr ')'
			{
				$$ = $2;
			}
			;
bool_base	:	expr compare expr
			{
				// Setting the type of Operand
				DataType type = BOOL_T;

				// Create destination operand
				Operand *dest = new Operand(Operand::REGISTER, getRegister(), type);

				// Create Instruction using $2 as the instruction
				Instruction inst ($2, *dest, *$1, *$3);

				// Add instruction to current block
				block -> pushBackInstruction(inst);
				
				// Remove source operands
				delete $1;
				delete $3;

				// Return destination operand
				$$ = dest;
			}
			|	TRUE
			{
				Operand *dest = new Operand(Operand::CONST, $1);
				$$ = dest; 
			}
			|	FALSE
			{
				Operand *dest = new Operand(Operand::CONST, $1);
				$$ = dest; 
			}
			|	ID
			{
				if (symbolTable.find($1)){
					// Variable is declared, we can assign new value.
					
					// Get the node for the variable
					Node temp = symbolTable.getNode($1);

					
					// Correct type. Update variable
					if (temp.getDataType() == BOOL_T){
						Operand *dest = new Operand(Operand::REGISTER,temp.getRegister(), temp.getDataType());
						$$ = dest;
					} else {
						string errmsg = "Variable is not of type Bool to be evaluated!";
						yyerror(errmsg.c_str());
					}
				} else {
					// Variable is not declared. Print errors.
					string errmsg = "Variable is not declared!";
					yyerror(errmsg.c_str());
				}
			}
			;
compare		:	LT {$$ = Instruction::LESS_THAN;}
			|	GT {$$ = Instruction::GREATER_THAN;}
			|	EQ {$$ = Instruction::EQUAL;}
			|	NE {$$ = Instruction::INEQUAL;}
			|	LE {$$ = Instruction::LESS_EQUAL;}
			|	GE {$$ = Instruction::GREATER_EQUAL;}
			;
expr		:	expr '+' term
			{
				// Setting the type of Operand
				DataType type = INT_T;
				if ($1->getDataType() == FLOAT_T || $3->getDataType() == FLOAT_T)
					type = FLOAT_T;

				// Create destination operand
				Operand *dest = new Operand(Operand::REGISTER, getRegister(), type);

				// Create a divide instruction
				Instruction inst (Instruction::ADD, *dest, *$1, *$3);

				// Add instruction to current block
				block -> pushBackInstruction(inst);
				
				// Remove source operands
				delete $1;
				delete $3;

				// Return destination operand
				$$ = dest;
			}

			|	expr '-' term
			{ 
				// Setting the type of Operand
				DataType type = INT_T;
				if ($1->getDataType() == FLOAT_T || $3->getDataType() == FLOAT_T)
					type = FLOAT_T;

				// Create destination operand
				Operand *dest = new Operand(Operand::REGISTER, getRegister(), type);

				// Create a divide instruction
				Instruction inst (Instruction::SUB, *dest, *$1, *$3);

				// Add instruction to current block
				block -> pushBackInstruction(inst);
				
				// Remove source operands
				delete $1;
				delete $3;

				// Return destination operand
				$$ = dest;
			}

			|	term 							{ $$ = $1; }
			;
term		:	term '*' factor
			{ 
				// Setting the type of Operand
				DataType type = INT_T;
				if ($1->getDataType() == FLOAT_T || $3->getDataType() == FLOAT_T)
					type = FLOAT_T;

				// Create destination operand
				Operand *dest = new Operand(Operand::REGISTER, getRegister(), type);

				// Create a divide instruction
				Instruction inst (Instruction::MUL, *dest, *$1, *$3);

				// Add instruction to current block
				block -> pushBackInstruction(inst);
				
				// Remove source operands
				delete $1;
				delete $3;

				// Return destination operand
				$$ = dest;
			}

			|	term '/' factor 				
			{
				// Setting the type of Operand
				DataType type = INT_T;
				if ($1->getDataType() == FLOAT_T || $3->getDataType() == FLOAT_T)
					type = FLOAT_T;

				// Create destination operand
				Operand *dest = new Operand(Operand::REGISTER, getRegister(), type);

				// Create a divide instruction
				Instruction inst (Instruction::DIV, *dest, *$1, *$3);

				// Add instruction to current block
				block -> pushBackInstruction(inst);

				// Remove source operands
				delete $1;
				delete $3;

				// Return destination operand
				$$ = dest;
			}
			|	factor							{ $$ = $1; }
			;
factor		:	'(' expr ')'					{ $$  = $2;}
			|	INT_VAL							
			{ 
				Operand *dest = new Operand(Operand::CONST, $1);
				$$ = dest; 
			}
			|	FLOAT_VAL							
			{ 
				Operand *dest = new Operand(Operand::CONST, $1);
				$$ = dest; 
			}
			|	ID
			{
				if (symbolTable.find($1)){
					// Variable is declared, we can assign new value.
					
					// Get the node for the variable
					Node temp = symbolTable.getNode($1);

					
					// Correct type. Update variable
					if (temp.getDataType() == INT_T || temp.getDataType() == FLOAT_T){
						Operand *dest = new Operand(Operand::REGISTER,temp.getRegister(), temp.getDataType());
						$$ = dest;
					} else {
						string errmsg = "Variable is not of type Int or Float to be calculated";
						yyerror(errmsg.c_str());
					}
				} else {
					// Variable is not declared. Print errors.
					string errmsg = "Variable is not declared!";
					yyerror(errmsg.c_str());
				}
			}
			;

%%
/* additional c code*/\

int yyerror(char const *errmsg){
	fprintf(stderr, "%s\n", errmsg);
}

int main(){
	printf("Type some input. Enter ? for help.\n");
	yyparse();

	return 0;
}
