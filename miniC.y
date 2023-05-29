%{
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <stdarg.h>
#include "table_symbole_function.c"
%}


%token ID CONSTANTE VOID INT FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token BREAK RETURN PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR LAND LOR LT GT 
%token GEQ LEQ EQ NEQ NOT EXTERN PVIRG VIRG
%token LCROCHET RCROCHET LACCOLADE RACCOLADE LPAR RPAR TWOP
%left PLUS MOINS
%left MUL DIV
%left LSHIFT RSHIFT
%left BOR BAND
%left LAND LOR

%nonassoc THEN
%nonassoc ELSE

%left OP
%left REL
%start programme
%%



programme	:	
		liste_declarations liste_fonctions
;
liste_declarations	:	
		liste_declarations declaration 
	|	
;
liste_fonctions	:	
		liste_fonctions fonction
|               fonction
;
declaration	:	
		type liste_declarateurs PVIRG
;
liste_declarateurs	:	
		liste_declarateurs VIRG declarateur
	|	declarateur
;
declarateur	:	
		ID
	|	declarateur LCROCHET CONSTANTE RCROCHET
;
fonction	:	
		type ID LPAR liste_parms RPAR LACCOLADE liste_declarations liste_instructions RACCOLADE
	|	EXTERN type ID LPAR liste_parms RPAR PVIRG
;
type	:	
		VOID
	|	INT
;
liste_parms	:	
		liste_parms VIRG parm
	|	
;
parm	:	
		INT ID
;
liste_instructions :	
		liste_instructions instruction
	|
;
instruction	:	
		iteration
	|	selection
	|	saut
	|	affectation PVIRG
	|	bloc
	|	appel
;
iteration	:	
		FOR LPAR affectation PVIRG condition PVIRG affectation RPAR instruction
	|	WHILE LPAR condition RPAR instruction
;
selection	:	
		IF LPAR condition RPAR instruction %prec THEN
	|	IF LPAR condition RPAR instruction ELSE instruction
	|	SWITCH LPAR expression RPAR instruction
	|	CASE CONSTANTE TWOP instruction
	|	DEFAULT TWOP instruction
;
saut	:	
		BREAK PVIRG
	|	RETURN PVIRG
	|	RETURN expression PVIRG
;
affectation	:	
		variable '=' expression
;
bloc	:	
		LACCOLADE liste_declarations liste_instructions RACCOLADE
;
appel	:	
		ID LPAR liste_expressions RPAR PVIRG
;
variable	:	
		ID
	|	variable LCROCHET expression RCROCHET
;
expression	:	
		LPAR expression RPAR
	|	expression binary_op expression %prec OP
	|	MOINS expression
	|	CONSTANTE
	|	variable
	|	ID LPAR liste_expressions RPAR
;
liste_expressions	:	
		liste_expressions VIRG expression
	|
;
condition	:	
		NOT LPAR condition RPAR
	|	condition binary_rel condition %prec REL
	|	LPAR condition RPAR
	|	expression binary_comp expression
;
binary_op	:	
		PLUS
	|   MOINS
	|	MUL
	|	DIV
	|   LSHIFT
	|   RSHIFT
	|	BAND
	|	BOR
;
binary_rel	:	
		LAND
	|	LOR
;
binary_comp	:	
		LT
	|	GT
	|	GEQ
	|	LEQ
	|	EQ
	|	NEQ
;
%%
