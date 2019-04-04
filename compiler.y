%defines

%code requires {
	/* C declarations and #DEFINE statement */
	#include <stdio.h>
	#include <cstring>
	#include "BasicBlock.hpp"
	#include "SymbolTable.hpp"
	#include "iostream"

	int yyerror(char *errmsg);
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
	int i_val;
	double f_val;
	char *s_val;
	Operand *operand;
}

/* Bison token declaration */
%token INT FLOAT VOID
%token INT_VAL STR_VAL FLOAT_VAL ID 
%right ASSGN
%left '+' '-'
%left '*' '/'
%token NEWLINE ';'

%type <i_val>  INT_VAL
%type <f_val>  FLOAT_VAL
%type <s_val> STR_VAL ID
%type <operand>	factor term expr

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
			|	';'
			;
stmt_decl 	:	INT ID ASSGN expr ';'		
			{ 
				if (!symbolTable.find($2)){
					// Create destination operand
					int registerNo = getRegister();
					Operand *dest = new Operand(Operand::REGISTER,registerNo);

					// Create a divide instruction
					Instruction inst (Instruction::STORE, *dest, *$4);

					// Add instruction to current block
					block -> pushBackInstruction(inst);
					
					// Remove source operands
					delete $4;

					symbolTable.insert($2, registerNo, Node::INT, Node::GLOBAL, 0);
				} else {
					// The variable is already declared. Print errors
				}
			}
			
			|	FLOAT ID ASSGN FLOAT_VAL ';'	{ }
			;
stmt_assgn  :	ID ASSGN expr ';'
			{
				if (symbolTable.find($1)){
					// Variable is declared, we can assign new value.
					
					// Get the node for the variable
					Node temp = symbolTable.getNode($1);

					// Check to see correct type
					if (temp.getType() == Node::INT){
						// Correct type. Update variable
						Operand *dest = new Operand(Operand::REGISTER,temp.getRegister());

						// Create a divide instruction
						Instruction inst (Instruction::STORE, *dest, *$3);

						// Add instruction to current block
						block -> pushBackInstruction(inst);
					} else {
						// Wrong type. Errors
					}
				} else {
					// Variable is not declared. Print errors.
				}
			}
			;
expr		:	expr '+' term
			{ 
				// Create destination operand
				Operand *dest = new Operand(Operand::REGISTER, getRegister());

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
				// Create destination operand
				Operand *dest = new Operand(Operand::REGISTER, getRegister());

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
				// Create destination operand
				Operand *dest = new Operand(Operand::REGISTER, getRegister());

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
				// Create destination operand
				Operand *dest = new Operand(Operand::REGISTER, getRegister());

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
			|	ID
			{
				if (symbolTable.find($1)){
					// Variable is declared, we can assign new value.
					
					// Get the node for the variable
					Node temp = symbolTable.getNode($1);

					// Check to see correct type
					if (temp.getType() == Node::INT){
						// Correct type. Update variable
						Operand *dest = new Operand(Operand::REGISTER,temp.getRegister());
						$$ = dest;
					} else {
						// Wrong type. Errors
					}
				} else {
					// Variable is not declared. Print errors.
				}
			}
			;

%%
/* additional c code*/\

int yyerror(char *errmsg){
	printf("%s\n", errmsg);
}

int main(){
	printf("Type some input. Enter ? for help.\n");
	yyparse();

	return 0;
}
