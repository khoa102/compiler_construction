%defines

%code requires {
	/* C declarations and #DEFINE statement */
	#include <stdio.h>
	#include <cstring>
	#include "BasicBlock.hpp"
	#include "iostream"

	int yyerror(char *errmsg);
	int yylex(void);
}

%code{	
	BasicBlock* block = new BasicBlock(0);
	int register_count = 0;
	int getRegister(){
		register_count++;
		return register_count-1;
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
func_def 	:	type ID '(' param_lists ')'  stmt_block NEWLINE 	{printf("Function def\n");}
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
stmt 		:	stmt_assgn
			|	';'
			;
stmt_assgn 	:	INT ID ASSGN INT_VAL ';'		{ }
			|	FLOAT ID ASSGN FLOAT_VAL ';'	{ }
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
				// This is a temporary value. It should use the register number that is stored inside the symbol table.
				int register_count = getRegister();
				Operand *dest = new Operand(Operand::REGISTER, register_count);
				$$ = dest;
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
