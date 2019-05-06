%defines

%code requires {
	/* C declarations and #DEFINE statement */
	#include <stdio.h>
	#include <cstring>
	#include "BasicBlock.hpp"
	#include "SymbolTable.hpp"
	#include "ControlFlowGraph.hpp"
	#include <iostream>

	int yyerror(char const *errmsg);
	int yylex(void);
}

%code{	
	// very first block
	BasicBlock* beginBlock;

	// Control flow graph (CFG)
	Graph* CFG;
	
	// declare a pointer to the current block
	BasicBlock* currentBlock;

	// structure of if_block_ids
	typedef struct if_stmt_struct {
		BasicBlock* begin_block;
		BasicBlock* true_block;
		BasicBlock* end_block;
	} if_stmt_blocks;

	if_stmt_blocks if_stmt;

	SymbolTable symbolTable;
	int registerCount = 0;
	int getRegister(){
		registerCount++;
		return registerCount-1;
	}	

	int blockID = 1;
	int getBlockID() {
		blockID ++;
		return blockID - 1;
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
%left '(' ')'
%token NEWLINE ';'

%type <i_val>  	INT_VAL
%type <f_val>  	FLOAT_VAL
%type <s_val>  	STR_VAL ID
%type <c_val>	CHAR_VAL
%type <b_val>	TRUE FALSE 
%type <operand>	factor term expr bool_base bool_expr
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
			}
			;
func_def 	:	type ID '(' param_lists ')'   	
			{
				// Create a new block for the body of the function
				currentBlock = new BasicBlock(getBlockID());

				// Add the block to the CFG
				CFG->addEdge(CFG->lastAddedBlockID, *currentBlock);
			}	
				stmt_block NEWLINE
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
					currentBlock -> pushBackInstruction(inst);
					
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
					currentBlock -> pushBackInstruction(inst);
					
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
						currentBlock -> pushBackInstruction(inst);
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
stmt_if		: 	if %prec '+'
			{
				// emit jump without condition instruction
				Instruction inst(Instruction::JUMP, Operand(Operand::LABEL, if_stmt.end_block->blockID));

				// push it to the begin_block
				if_stmt.begin_block->pushBackInstruction(inst);

				// add blocks to graph
				CFG->addEdge(CFG->lastAddedBlockID, *(if_stmt.begin_block));
				CFG->addEdge(if_stmt.begin_block->blockID, *(if_stmt.true_block));

				// continue codes after if-statement
				currentBlock = if_stmt.end_block;

				delete if_stmt.begin_block;
				delete if_stmt.true_block;
			}
			|	if ELSE 
			{
				currentBlock = if_stmt.begin_block;
			}
			stmt_block %prec '*'		// all instructions here are added to begin_block
			{
				// emit jump without condition instruction
				Instruction inst(Instruction::JUMP, Operand(Operand::LABEL, if_stmt.end_block->blockID));

				// push it to the begin_block
				if_stmt.begin_block->pushBackInstruction(inst);

				// add blocks to graph
				CFG->addEdge(CFG->lastAddedBlockID, *(if_stmt.begin_block));
				CFG->addEdge(if_stmt.begin_block->blockID, *(if_stmt.true_block));

				// continue codes after if-statement
				currentBlock = if_stmt.end_block;

				delete if_stmt.begin_block;
				delete if_stmt.true_block;
			}
			;
if			:	IF '(' bool_expr ')' 
				{
					/****** if condition part ******/
					if_stmt.begin_block = currentBlock;	

					if_stmt.true_block = new BasicBlock(getBlockID()); 

					// emit jump with condition instruction
					Instruction inst(Instruction::JUMP_TRUE, Operand(Operand::LABEL, if_stmt.true_block->blockID), *$3);

					// push it to the begin_block
					if_stmt.begin_block->pushBackInstruction(inst);

					// set currentBlock to true_block
					currentBlock = if_stmt.true_block;
					
					delete $3;
				}
				stmt_block
				{
					/***** if_true block ****/
					if_stmt.end_block = new BasicBlock(getBlockID());

					Instruction inst(Instruction::JUMP, Operand(Operand::LABEL, if_stmt.end_block->blockID));

					// push it to the true_block
					if_stmt.true_block->pushBackInstruction(inst);
				}
			{

			}
			;
bool_expr	:	 bool_base LO_OR bool_expr 
			{
				// Setting the type of Operand
				DataType type = BOOL_T;

				// Create destination operand
				Operand *dest = new Operand(Operand::REGISTER, getRegister(), type);

				// Store the first part into the register. This is so that data in $1 and $3 remain unchanged.
				Instruction inst (Instruction::STORE, *dest, *$3);

				// Add instruction to current block
				currentBlock -> pushBackInstruction(inst);
				
				// Doing the AND operation
				Instruction inst2 (Instruction::AND, *dest, *$1);
				currentBlock -> pushBackInstruction(inst2);

				// Remove source operands
				delete $1;
				delete $3;

				// Return destination operand
				$$ = dest;
			}
			|	 bool_base LO_AND bool_expr 
			{
				// Setting the type of Operand
				DataType type = BOOL_T;

				// Create destination operand
				Operand *dest = new Operand(Operand::REGISTER, getRegister(), type);

				// Store the first part into the register. This is so that data in $1 and $3 remain unchanged.
				Instruction inst (Instruction::STORE, *dest, *$1);

				// Add instruction to current block
				currentBlock -> pushBackInstruction(inst);
				
				// Doing the AND operation
				Instruction inst2 (Instruction::AND, *dest, *$3);
				currentBlock -> pushBackInstruction(inst2);

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
bool_base	:	expr compare expr
			{
				// Setting the type of Operand
				DataType type = BOOL_T;

				// Create destination operand
				Operand *dest = new Operand(Operand::REGISTER, getRegister(), type);

				// Create Instruction using $2 as the instruction
				Instruction inst ($2, *dest, *$1, *$3);

				// Add instruction to current block
				currentBlock -> pushBackInstruction(inst);
				
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
			|	'(' bool_expr ')'
			{
				$$ = $2;
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
				currentBlock -> pushBackInstruction(inst);
				
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
				currentBlock -> pushBackInstruction(inst);
				
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
				currentBlock -> pushBackInstruction(inst);
				
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
				currentBlock -> pushBackInstruction(inst);

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
	beginBlock = new BasicBlock(0);

	// add it to the graph as a base block
	CFG = new Graph(*beginBlock);

	// create the current block
	currentBlock = new BasicBlock(getBlockID());

	// call parser
	yyparse();

	// add the current block to CFG
	CFG->addEdge(CFG->lastAddedBlockID, *currentBlock);

	CFG->dumpGraph();

	//cout << "\n\n... Symbol table ... \n" << symbolTable.dumpSymbolTable() << endl;

	delete currentBlock;
	delete CFG;

	return 0;
}
