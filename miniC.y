%{
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <stdarg.h>
#include "table_symbole_function.c"
#include "miniCfunctions.c"

#define MAXCHILD 100
#define ALLOUER_MEMOIRE 300
#define STRING_LENGTH 50
#define NUMBER_VARIABLE 200

extern void yyerror(const char*);
extern int yylex(void);

extern FILE *yyin;
extern FILE *yyout;

extern int yylineno;
extern int line;

int ERREUR_SEMANTIQUE = FALSE;
int ERREUR_SYNTAXE = FALSE;

void erreur_semantique(){
	ERREUR_SEMANTIQUE=TRUE;
}

void erreur_syntaxe(){
	ERREUR_SYNTAXE=TRUE;
}

char *none = "none";
int booleanVariableDefined = FALSE;

char *assign = "assign";
char *typeVariable = "";

char liste_vars[NUMBER_VARIABLE][STRING_LENGTH];
char liste_function[NUMBER_VARIABLE][STRING_LENGTH];


struct variable{
	char* nom;
	char* type;
};

struct variabe* liste_param_function[NUMBER_VARIABLE];


table_symbole_variable* tableSymbole_var[TAILLE_TABLE_VARIABLE];
table_function* tableSymbole_fun[TAILLE_TABLE_FUNCTION];


void add_variable(char *nom){
	for(int i = 0; i < NUMBER_VARIABLE; i++){
		if (strcmp(liste_vars[i], "") == 0 && strcmp(liste_vars[i], nom) != 0){
			strcpy(liste_vars[i], nom);
			break;
		}
	}
}

void complete_table_variable(table_symbole_variable** tab, char* type){
	for(int i = 0; i <= NUMBER_VARIABLE; i++){
		if(strcmp(liste_vars[i], "") != 0){
			if(insert_table(tab, type, liste_vars[i]) != NULL){
				display(tab, liste_vars[i]);
			}
			else{
				erreur_semantique();
			}
		}
	}
}

void add_function(char *nom){
	for (int i = 0; i < NUMBER_VARIABLE; i++){
		if (strcmp(liste_function[i], "") == 0){
			strcpy(liste_function[i], nom);
			break;
		}
	}
}

void add_parametre_function(char* nom, char* type){
	for(int i = 0; i < NUMBER_VARIABLE; i++){
		if (liste_param_function[i] == NULL){
			liste_param_function[i] = (struct variable*) malloc(sizeof(struct variable));//?
			liste_param_function[i]->nom = nom;
			liste_param_function[i]->type = type;
			break;
		}
	}
}


int check_function_declared(){
	for(int i = 0; i < NUMBER_VARIABLE; i++){
		if(strcmp(liste_function[i], "") != 0){
			if (find_function(tableSymbole_fun, liste_function[i]) == FALSE){
				return FALSE;
			}
		}
	}
	return TRUE;
}

void complete_table_function(table_function** tab, char* nom_function){
	display_function(tab, nom_function);
	for(int i = 0; i < NUMBER_VARIABLE; i++){
		if (liste_param_function[i] != NULL){
			insert_params(tab, nom_function, liste_param_function[i]->type, liste_param_function[i]->nom);
			display_function_param(tab, nom_function, liste_param_funtion[i]->nom);
		}
	}
}


void vider_liste_variable_temporaire(){
	int p=0;
	for(p=0;p< NUMBER_VARIABLE;p++){
		strcpy(liste_vars[p],"");
	}
}

void vider_liste_params_temporaire(){
	int p=0;
	for(p=0;p< NUMBER_VARIABLE;p++){
		liste_param_function[p]=NULL;
	}
}




// TREE

struct treeNode{
    struct treeNode *child[MAXCHILD];
    char* nodeType;
    char* decorationDot;
    char* valueDot;
    char* value;
    int lineNo;
    int Nchildren;
};

struct treeNode *arbre ;

void storeTree( struct treeNode* node){
    arbre = (struct treeNode*) malloc(sizeof(struct treeNode));
    arbre = node;
}

char* decoration_dot(char* nom){
	if(strcmp(nom,"BREAK")==0){

		return "shape=square ";
		
	}else if(strcmp(nom,"appel")==0){

		return "shape=septagon ";
		
	}else if(strcmp(nom,"RETURN")==0){

		return "shape=trapezium color=blue ";
		
	}else if(strcmp(nom,"IF")==0){

		return "shape=diamond";
		
	}else if(strcmp(nom,"function")==0){

		return "shape=invtrapezium color=blue";
		
	}else{
		return "";
	}
}


char* nom_fichier(char* path){
	
	char* nom = strrchr(path,'/');
	if (nom == NULL){
		nom = path;
	}
	else {
		nom++;
	}
	return strdup(nom);
}


void printNodeParam(struct treeNode* arbre, FILE* fp){
	int i;
	if (arbre->Nchildren == 0){
		return ;
	}
	
	else if (arbre->Nchildren > 0){
		for (i = 0; i < arbre->Nchildren; i++){
			if (arbre->child[i] == NULL){
				return ;
			}
			else {
				if (strcmp(arbre->nodeType, arbre->child[i]->nodeType) == 0){
					printNodeParam(arbre->child[i], fp);
				}
				else {
					if (strcmp(arbre->child[i]->nodeType, "func") == 0){
						printNodeParam(arbre->child[i], fp);
					}
					else{
						fprintf(fp," %s [label= \"%s\" %s] \n", arbre->child[i]->value, arbre->child[i]->valueDot, decoration_dot(arbre->child[i]->decorationDot));
						printNodeParam(arbre->child[i],fp);
					}
				}
			}
		}
	}
}

int skipChildTab(struct treeNode* node){
	
	if(node->child[0]==NULL || strcmp(node->child[0]->valueDot,"TAB")!=0) {return 0;}
	else{
		
		node->child[0]->nodeType=node->nodeType;
		node->child[0]->value=node->nodeType;
		
	}
	skipChildTab(node->child[0]);
}

int skipChildSelec(struct treeNode* node){
	
	if(node->child[0]==NULL ){return 0;}
	else{
		if((strcmp(node->valueDot,"ignore")==0 ) && (strcmp(node->child[0]->valueDot,"ignore")==0 ) ){

		node->child[0]->nodeType=node->nodeType;}
		
	}
	skipChildSelec(node->child[0]);
}


void printNodeDot(struct treeNode* arbre, FILE* fp){
	int i;
	int k;

	if (arbre->Nchildren == 0){return;}
	
	else if(arbre->Nchildren > 0){
		for (i = 0; i < arbre->Nchildren; i++){
			if (arbre->child[i] == NULL){return;}
			if(arbre->nodeType == arbre->child[i]->nodeType || strcmp(arbre->nodeType, "liste_fonctions") == 0 ||  strcmp(arbre->nodeType, "func") == 0){
				printNodeDot(arbre->child[i], fp);
			}
			else{
				fprintf(fp,"%s -> ",  arbre->nodeType );
				fprintf(fp,"%s \n", arbre->child[i]->value);
				if (strcmp (arbre->child[i]->value, "BLOC") == 0){
					arbre->nodeType = "BLOC";
				}
				printNodeDot(arbre->child[i], fp);
			}
		}
	}
}

void genererDot(struct treeNode* arbre, char* path){
	FILE * fp;
	char* pathFile = malloc(strlen(path)+STRING_LENGTH);
	
	strncat(pathFile,path,strlen(path)-2);
	strncat(pathFile,".dot",strlen(path));
	
	fp = fopen(nom_fichier(pathFile), "wb");
	
	
	fprintf(fp," digraph G { \n");
	fprintf(fp,"{ \n");
	printNodeParam(arbre,fp);
	fprintf(fp,"} \n");
	printNodeDot(arbre,fp);
	fprintf(fp,"} \n");
	
	fclose (fp);

}


struct treeNode* newnode(int lineNo, char* decorationDot, char* nodeType, char* value, char* valueDot, int Nchildren, ...){
	struct treeNode* node = (struct treeNode*) malloc (sizeof(struct treeNode));
	
	va_list ap;
	va_start(ap, Nchildren);

	for (int i = 0; i < Nchildren; i++){
		node->child[i] = va_arg(ap, struct treeNode *);
	}
	va_end(ap);

	char* string_nodeType= (char*) malloc(ALLOUER_MEMOIRE);
	sprintf(string_nodeType,"n_%s_%d_n",nodeType,auto_incrementor);
	
	if(strcmp(nodeType,"liste_fonctions")==0 || strcmp(nodeType,"BLOC")==0 || strcmp(nodeType,"func")==0){
		node->nodeType=nodeType;
	}
	
	else{
		node->nodeType=string_nodeType;
	}
	
	if(strcmp(nodeType,"BLOC")==0){
		node->value = value;
	
	}else{
		char* string_value= (char*) malloc(ALLOUER_MEMOIRE);
		sprintf(string_value,"n_%s_%d_n",value,auto_incrementor);
		node->value=string_value;
	}

	auto_incrementor++;
	node->lineNo = lineNo;
	node->valueDot = valueDot;
	node->Nchildren = Nchildren;
	node->decorationDot = decorationDot;
	
	char* string_nodeFunction= (char*) malloc(ALLOUER_MEMOIRE);
	char* string_nodeSelection= (char*) malloc(ALLOUER_MEMOIRE);
	char* string_nodeTAB= (char*) malloc(ALLOUER_MEMOIRE);
	char* string_nodeAssign= (char*) malloc(ALLOUER_MEMOIRE);
	sprintf(string_nodeFunction,"n_function_%d_n",auto_incrementor-1);
	sprintf(string_nodeAssign,"n_assign_%d_n",auto_incrementor-2);
	sprintf(string_nodeTAB,"n_TAB_%d_n",auto_incrementor-1);
	sprintf(string_nodeSelection,"n_selection_%d_n",auto_incrementor-1);

	
	if(node->child[0]!= NULL && strcmp(node->child[0]->nodeType,string_nodeAssign)!=0  && strcmp(node->nodeType,string_nodeFunction)==0  ){
		node->child[0]->nodeType=string_nodeType;
		
	}

	if(node->child[node->Nchildren-1]!= NULL && strcmp(node->nodeType,string_nodeSelection)==0 && 
		strcmp(node->child[node->Nchildren-1]->valueDot,"ignore")==0 ){
		node->child[node->Nchildren-1]->nodeType=node->nodeType;
		
	}
	
	if(strcmp(node->nodeType,string_nodeSelection)==0){
		skipChildSelec(node);
		
	}
	
	if(strcmp(node->nodeType,string_nodeTAB)==0){
		
		skipChildTab(node);
	}
	return node;

}



%}

%union {
    char* str;
    struct treeNode * ast;
    struct variable * variable;
}

%token VOID INT FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token BREAK RETURN PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR LAND LOR LT GT 
%token GEQ LEQ EQ NEQ NOT EXTERN PVIRG VIRG
%token LCROCHET RCROCHET LACCOLADE RACCOLADE LPAR RPAR TWOP
%token <str> ID CONSTANTE

%left PLUS MOINS
%left MUL DIV
%left LSHIFT RSHIFT
%left BOR BAND
%left LAND LOR

%nonassoc THEN
%nonassoc ELSE

%left OP
%left REL


%type<ast> arbre programme liste_fonctions fonction liste_instructions instruction expression saut affectation liste_expressions variable binary_op appel condition selection iteration binary_comp binary_rel bloc affectation_for postfix_expression liste_instructions2 
%type<str> type liste_declarations declaration liste_declarateurs declarateur liste_parms parm


%start programme




%%

arbre:programme {storeTree($1);}

programme	:	
		liste_declarations liste_fonctions {$$ = $2;}
;
liste_declarations	:	
		liste_declarations declaration 
	|	
;
liste_fonctions	:	
		liste_fonctions fonction {$$ = newnode(yylineno, "", "liste_fonctions", "liste_fonctions", none, 2, $1, $2); }
|               fonction		 {$$ = newnode(yylineno, "", "func", "func", none, 1, $1); }
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
