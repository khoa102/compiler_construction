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
"char"						return CHAR;
"bool"						return BOOL;
"true"						return TRUE;
"false"						return FALSE;
"if"						return IF;
"else"						return ELSE;
\'{alpha}\'					{yylval.c_val = yytext[0]; return CHAR_VAL;}
-?{digit}+					{yylval.i_val = atoi(yytext); return INT_VAL;}	
{digit}+\.[0-9]+"f"?		{yylval.f_val = atof(yytext); return FLOAT_VAL;}
\"[a-zA-Z0-9 ]+\"			{yylval.s_val = strdup(yytext); return STR_VAL;}
{alpha}({digit}|{alpha})*	{yylval.s_val = strdup(yytext); return ID;}
"="							return ASSGN;
"=="						return EQ;
"!="						return NE;
"<"							return LT;
"<="						return LE;
">"							return GT;
">="						return GE;
"&&"						return LO_AND;
"\|\|"						return LO_OR;
[-+*/(){};,]				{return (int) yytext[0];}
[\n]        				{ return NEWLINE; }
[ \t]+      				/* ignore whitespace */;
