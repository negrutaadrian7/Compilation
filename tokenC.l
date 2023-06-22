

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h> 
#include "y.tab.h"
extern void yyerror(const char *);
extern int sym_type(const char *); 

void comment(void);
int line=0;

%}


L [a-zA-Z_]
A [a-zA-Z_0-9]
C [0-9]
%option yylineno



%%

"/*"            { comment(); }
"//".*          { /* ignore comment */ }


"break"		return BREAK;
"for" 		return FOR;
"while"		return WHILE;
"if"		return IF;
"else"		return ELSE;
"switch"	return SWITCH;
"case"		return CASE;
"default"	return DEFAULT;
"return" 	return RETURN;
"extern"	return EXTERN;

{C}+                    {yylval.str= strdup(yytext); return CONSTANTE;}
"void"		            {yylval.str = strdup(yytext); return VOID;}
"int"		            {yylval.str = strdup(yytext); return INT;}
{L}{A}* 	            {yylval.str= strdup(yytext); return ID;}


"+"		    return PLUS ;
"-" 		return MOINS;
"="		    return EQ;
"=="		return EQEQ;
"/"		    return DIV;
"(" 		return LPAR;
")"		    return RPAR;
"*" 		return MUL;
"!"		    return NOT;
";"		    return PVIRG;
","		    return VIRG;
"["		    return LCROCHET;
"]"		    return RCROCHET;
"{"		    return LACCOLADE;
"}"		    return RACCOLADE;
"<"		    return LT;
">"		    return GT;
">="		return GEQ;
"<=" 		return LEQ;
"!="		return NEQ;
"<<"		return LSHIFT;
">>" 		return RSHIFT;
":"  		return TWOP; 
"&&"		return LAND;
"||"		return LOR;
"&"		    return BAND;
"|"		    return BOR;


"\n"			    {line++;}
[\t\f\v\r ]+		{ /* IGNORE whitespace */ }
.		            { fprintf(stderr, "Line %d : unexpected character `%c'\n", line, yytext[0]); }

%%


int yywrap(void)        
{
    return 1;           
}

void comment(void)
{
    int c;

    while ((c = input()) != 0)
        if (c == '*')
        {
            while ((c = input()) == '*')
                ;

            if (c == '/')
                return;

            if (c == 0)
                break;
        }
    yyerror("unterminated comment");
}





