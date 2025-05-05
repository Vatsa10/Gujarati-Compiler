
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
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


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     NUMBER = 258,
     PRINT = 259,
     WHITESPACE = 260,
     NEWLINE = 261,
     EXIT = 262,
     HELP = 263,
     STRING = 264,
     OBRACE = 265,
     CBRACE = 266,
     IF = 267,
     THEN = 268,
     ELSE = 269,
     GT = 270,
     LT = 271,
     EQ = 272,
     GE = 273,
     LE = 274,
     NE = 275,
     AND = 276,
     OR = 277,
     EXOR = 278,
     ADD = 279,
     SUB = 280,
     MUL = 281,
     DIV = 282,
     MOD = 283,
     ANDAND = 284,
     OROR = 285
   };
#endif
/* Tokens.  */
#define NUMBER 258
#define PRINT 259
#define WHITESPACE 260
#define NEWLINE 261
#define EXIT 262
#define HELP 263
#define STRING 264
#define OBRACE 265
#define CBRACE 266
#define IF 267
#define THEN 268
#define ELSE 269
#define GT 270
#define LT 271
#define EQ 272
#define GE 273
#define LE 274
#define NE 275
#define AND 276
#define OR 277
#define EXOR 278
#define ADD 279
#define SUB 280
#define MUL 281
#define DIV 282
#define MOD 283
#define ANDAND 284
#define OROR 285




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


