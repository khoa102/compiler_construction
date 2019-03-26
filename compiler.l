%option noyywrap

%{
	#include "compiler.tab.h"
%}
alpha [a-zA-Z]
digit [0-9]

%%
"int"						return INT;
"float"						return FLOAT;
"void"						return VOID;
-?{digit}+					{yylval.i_val = atoi(yytext); return INT_VAL;}	
{digit}+\.[0-9]+"f"?		{yylval.f_val = atof(yytext); return FLOAT_VAL;}
\"[a-zA-Z0-9 ]+\"			{yylval.s_val = strdup(yytext); return STR_VAL;}
{alpha}({digit}|{alpha})*	{yylval.s_val = strdup(yytext); return ID;}
"="							return ASSGN;
[-+*/(){};,]				{return (int) yytext[0];}
[\n]        				{ return NEWLINE; }
[ \t]+      				/* ignore whitespace */;
