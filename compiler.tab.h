/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_COMPILER_TAB_H_INCLUDED
# define YY_YY_COMPILER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif
/* "%code requires" blocks.  */
#line 3 "compiler.y" /* yacc.c:1909  */

	/* C declarations and #DEFINE statement */
	#include <stdio.h>
	#include <cstring>
	#include "BasicBlock.hpp"
	#include "SymbolTable.hpp"
	#include "ControlFlowGraph.hpp"
	#include <iostream>

	int yyerror(char const *errmsg);
	int yylex(void);

#line 57 "compiler.tab.h" /* yacc.c:1909  */

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    INT = 258,
    FLOAT = 259,
    VOID = 260,
    CHAR = 261,
    BOOL = 262,
    INT_VAL = 263,
    STR_VAL = 264,
    FLOAT_VAL = 265,
    ID = 266,
    TRUE = 267,
    FALSE = 268,
    CHAR_VAL = 269,
    IF = 270,
    ELSE = 271,
    ASSGN = 272,
    LO_OR = 273,
    LO_AND = 274,
    EQ = 275,
    NE = 276,
    LE = 277,
    GE = 278,
    LT = 279,
    GT = 280,
    NEWLINE = 281
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 48 "compiler.y" /* yacc.c:1909  */

	int 	i_val;
	double 	f_val;
	char    c_val;
	bool	b_val;
	char 	*s_val;
	Operand *operand;
	Instruction::Opcode  opcode;

#line 106 "compiler.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_COMPILER_TAB_H_INCLUDED  */
