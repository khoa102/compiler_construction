%defines

%code requires {
	/* C declarations and #DEFINE statement */
	#include <stdio.h>
	#include <cstring>
	#include "Instruction.hpp"

	int yyerror(char *errmsg);
	int yylex(void);
}
%union{
	int i_val;
	double f_val;
	char *s_val;
}

/* Bison token declaration */
%token INT FLOAT VOID
%token INT_VAL STR_VAL FLOAT_VAL ID 
%right ASSGN
%left '+' '-'
%left '*' '/'
%token NEWLINE ';'

%type <i_val> factor INT_VAL
%type <f_val> term expr FLOAT_VAL
%type <s_val> STR_VAL ID

%% /* grammar rules */
input		: /* empty production for empty input */
			|	input line
			;
line		:	test_assign  NEWLINE										
			|	func_def
			;
test_assign :	ID ASSGN expr ';'											{printf("Result is %f\n", $3);}
func_def 	:	type ID '(' param_lists ')'  stmt_block NEWLINE 	{printf("Function def\n");}
			;
type 		:	INT
			|	FLOAT
			|	VOID
			;
param_lists : 
			|	PARAMS
			;	
PARAMS		: 	type ID ',' param_lists
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
stmt_assgn 	:	INT ID ASSGN INT_VAL ';'		{ printf("Assignemnt: int %s = %d\n", $2, $4);}
			|	FLOAT ID ASSGN FLOAT_VAL ';'	{ printf("Assignemnt: float %s = %f\n", $2, $4);}
			;
expr		:	expr '+' term 					{ $$ = $1 + $3; Operand dest(Operand::MEM_ADDRESS, 123);  Operand src1(Operand::MEM_ADDRESS, 123); Operand src2(Operand::MEM_ADDRESS, 123); Instruction inst (dest, src1, src2); printf(inst.dumpInstruction());}
			|	expr '-' term 					{ $$ = $1 - $3; }
			|	term 							{ $$ = $1; }
			;
term		:	term '*' factor 				{ $$ = (double) $1 * $3; }
			|	term '/' factor 				{ $$ = (double)$1 / $3; }
			|	factor							{ $$ = (double) $1; }
			;
factor		:	'(' expr ')'					{ $$ = $2; }
			|	INT_VAL							{ $$ = $1; }
			;


%%
/* additional c code*/


int yyerror(char *errmsg){
	printf("%s\n", errmsg);
}

int main(){
	printf("Type some input. Enter ? for help.\n");
	yyparse();

	return 0;
}
