%defines
%code requires {
	/* C declarations and #DEFINE statement */
	#include <stdio.h>
	#include <ctype.h>
	
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
line		:	expr  NEWLINE										{ printf("Result is %f\n", $1);}
			|	FUNC_DEF
			;
FUNC_DEF 	:	TYPE ID '(' PARAM_LISTS ')'  STMT_BLOCK NEWLINE 	{printf("Function def\n");}
			;
TYPE 		:	INT
			|	FLOAT
			|	VOID
			;
PARAM_LISTS : 
			|	PARAMS
			;	
PARAMS		: 	TYPE ID ',' PARAM_LISTS
			|	TYPE ID
			;
STMT_BLOCK 	:	'{' STMTS '}'
			|	STMT
			;
STMTS 		:	STMT STMTS
			|
			;
STMT 		:	STMT_ASSGN
			|	';'
			;
STMT_ASSGN 	:	INT ID ASSGN INT_VAL ';'		{ printf("Assignemnt: int %s = %d\n", $2, $4);}
			|	FLOAT ID ASSGN FLOAT_VAL ';'	{ printf("Assignemnt: float %s = %f\n", $2, $4);}
			;
expr		:	expr '+' term 					{ $$ = $1 + $3; }
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

void main(){
	printf("Type some input. Enter ? for help.\n");
	yyparse();
}
