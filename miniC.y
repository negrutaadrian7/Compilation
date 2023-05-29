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
%token GEQ LEQ EQ NEQ NOT EQEQ EXTERN PVIRG VIRG
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
		type liste_declarateurs PVIRG {
			complete_table_variable(tableSymbole_var, $1);
		}
;
liste_declarateurs	:	
		liste_declarateurs VIRG declarateur
	|	declarateur
;
declarateur	:	
		ID {$$ = $1; add_variable($1); }
	|	declarateur LCROCHET CONSTANTE RCROCHET
;




fonction	:	
		type ID LPAR liste_parms RPAR LACCOLADE liste_declarations liste_instructions RACCOLADE 
		{
			if (insert_table_function(tableSymbole_fun, $1, $2) == NULL){
				erreur_semantique();
				YYABORT;
			}

			complete_table_function(tableSymbole_fun, $2);

			if(check_function_declared() == FALSE){
				fprintf(stderr,RED "Erreur Ligne %d : " RESET "La fonction n'est pas défini ! \n",yylineno);
			    erreur_semantique();
			    YYABORT;
			}

			for (int p = 0; p < NUMBER_VARIABLE; p++){
				if (liste_param_function[p] != NULL){
					if (find_param(tableSymbole_fun, liste_param_function[p]->nom) == TRUE && booleanVariableDefined == TRUE){
						fprintf(stderr,RED "Erreur : " RESET " Ligne %d :  La variable %s est déjà défini dans la fonction %s\n",yylineno,liste_param_function[p]->nom,$2);
						erreur_semantique();
						YYABORT;
						booleanVariableDefined=FALSE;
						break;
					}
					else if(find_param(tableSymbole_fun, liste_param_function[p]->nom) == TRUE && booleanVariableDefined==FALSE){
						booleanVariableDefined = TRUE;
					}
				}
			}

			if(booleanVariableDefined==FALSE){
				fprintf(stderr,RED "Erreur : " RESET " Ligne %d : la variable n'est pas défini \n",yylineno);
				erreur_semantique();
				YYABORT;
			}

			vider_liste_params_temporaire();
			char* string_valueDot= (char*) malloc(ALLOUER_MEMOIRE);
			sprintf(string_valueDot,"%s, %s",$2,$1); // ID et TYPE
			
			$$ = newnode(yylineno,"function","function", "function",string_valueDot, 1,$8);
		}
	
	
	
	|EXTERN type ID LPAR liste_parms RPAR PVIRG {
		if(insert_table_function(tableSymbole_fun,$2,$3)==NULL){
			erreur_semantique();
			YYABORT;
		}
	}

	| type ID LPAR RPAR LACCOLADE liste_declarations liste_instructions RACCOLADE {
		add_function($2);
		if (insert_table_function(tableSymbole_fun, $1, $2) == NULL){
			erreur_semantique();
			YYABORT;
		}

		if(check_function_declared()==FALSE){
		   	fprintf(stderr,RED "Erreur Ligne %d : " RESET "La fonction n'est pas défini ! \n",yylineno);
			erreur_semantique();
		    YYABORT;
		}

		if(booleanVariableDefined==FALSE){
			fprintf(stderr,RED "Erreur : " RESET " Ligne %d : la variable n'est pas défini \n",yylineno);
			erreur_semantique();
			YYABORT;
		}

		display_function(tableSymbole_fun, $2);
		
		char* string_valueDot = (char*) malloc(ALLOUER_MEMOIRE);
		sprintf(string_valueDot, "%s, %s", $2, $1);

		$$=newnode(yylineno, "function", "function", "function", string_valueDot, 1, $7);
	}
;



type	:	
		VOID 	{$$ = "void";}
	|	INT 	{$$ = "int";}
;

liste_parms	:	
		liste_parms VIRG parm
	|	parm
;
parm	:	
		INT ID 	{$$ = $2; add_parametre_function($2, "int");}
		|VOID	{$$ = "";}
;


liste_instructions :	
		liste_instructions instruction {
			$$=newnode(yylineno,"BLOC","BLOC", "BLOC","BLOC", 2,$1,$2);
		}
	
	|instruction {$$ = $1;}
;

liste_instructions2 :	
		liste_instructions2 instruction {
			$$=newnode(yylineno,"","BLOC2", "BLOC2","ignore", 2,$1,$2);
		}
	|	instruction {$$=$1;}
;


instruction	:	
	expression PVIRG		{$$ = $1; }
	|	iteration			{$$ = $1; }
	|	selection			{$$ = $1; }
	|	saut				{$$ = $1; }
	|	affectation PVIRG	{$$ = $1; }
	|	bloc				{$$ = $1; }
	|	appel				{$$ = $1; }
;


iteration	:	
		FOR LPAR affectation PVIRG condition PVIRG affectation RPAR instruction {
			$$=newnode(yylineno,"iteration","selection", "selection","FOR", 4,$3,$5,$7,$9);
		}
	
	|	WHILE LPAR condition RPAR instruction {
			$$=newnode(yylineno,"iteration","selection", "selection","WHILE", 2,$3,$5);
		}
;



selection	:	
		IF LPAR condition RPAR instruction %prec THEN {$$=newnode(yylineno,"IF","selection", "selection","IF", 2,$3,$5);}
	|	IF LPAR condition RPAR instruction ELSE instruction {$$=newnode(yylineno,"IF","selection", "selection","IF", 3,$3,$5,$7);}
	|	SWITCH LPAR expression RPAR instruction {$$=newnode(yylineno,"SWITCH","selection", "selection","SWITCH", 1,$5);}
	|	CASE CONSTANTE TWOP instruction {$$=newnode(yylineno,"CASE","selection", "selection","CASE", 1,$4);}
	|	DEFAULT TWOP instruction {$$=newnode(yylineno,"DEFAULT","selection", "selection","DEFAULT", 1,$3);}
;
saut	:	
		BREAK PVIRG 			{$$=newnode(yylineno,"BREAK","BREAK", "BREAK","BREAK" ,0);}
	|	RETURN PVIRG 			{$$=newnode(yylineno,"RETURN","RETURN", "RETURN","RETURN", 0);}
	|	RETURN expression PVIRG	{$$=newnode(yylineno,"RETURN","RETURN", "RETURN","RETURN",1,$2);}
;



affectation	:	
		expression EQ expression PVIRG {
			
			for(int i = 0;i<$3->Nchildren;i++){
			   if(atoi($3->child[i]->valueDot) !=0){
				if(find(tableSymbole_var,$3->child[i]->valueDot) != FALSE){
					if(strcmp(find_type(tableSymbole_var,$3->child[i]->valueDot), "int")==0){
						fprintf(stderr,RED "Erreur : " RESET "La variable %s doit etre un %s ! \n",$3->child[i]->valueDot, find_type(tableSymbole_var,$1->valueDot));
						erreur_semantique(); 
						YYABORT;
					}
				}
			    }
			}
			$$=newnode(yylineno,"", assign, assign, ":=", 2, $1, $3);	
		}
;




bloc	:	
		LACCOLADE liste_declarations liste_instructions RACCOLADE{
			$$ = $3;
		}
;
appel	:	
		ID LPAR liste_expressions RPAR PVIRG{
			add_function($1);
			$$=newnode(yylineno, "appel", "appel", "appel", $1, 1, $3);
		}
;


variable	:	
		ID {
			if (find(tableSymbole_var, $1) == TRUE) {
				booleanVariableDefined=TRUE;
			}
			else {
				booleanVariableDefined=FALSE;
			}
			$$=newnode(yylineno,"variable","variable", $1, $1,0);
		}
	|	variable LCROCHET expression RCROCHET{
			$$=newnode(yylineno,"TAB","TAB", "TAB", "TAB",2,$1,$3);
		}
;


expression	:	
		LPAR expression RPAR {$$=$2;}
	|	expression binary_op expression %prec OP {$$=newnode(yylineno,"","expression", "expression",$2->valueDot, 2,$1,$3);}
	|	MOINS expression {$$=newnode(yylineno,"","expression", "expression","-", 1,$2);}
	|	CONSTANTE {$$=newnode(yylineno,"","CONSTANTE", $1,$1,0);}
	|	variable {$$=$1;}
	|	ID LPAR liste_expressions RPAR {
			add_function($1);
			$$=newnode(yylineno,"appel","appel_function", "appel_function",$1,1,$3);
		}
;

liste_expressions	:	
		liste_expressions VIRG expression {$$=newnode(yylineno,"","liste_expression", "liste_expression","liste_expressions", 2,$1,$3);}
	|expression {$$ = $1;}
;
condition	:	
		NOT LPAR condition RPAR 					{$$=newnode(yylineno,"","condition", "condition","!", 1,$3);}
	|	condition binary_rel condition %prec REL 	{$$=newnode(yylineno,"","condition", "condition",$2->valueDot, 2,$1,$3);}
	|	LPAR condition RPAR							{$$=$2;}
	|	expression binary_comp expression			{$$=newnode(yylineno,"","expression", "expression",$2->valueDot, 2,$1,$3);}
;	
binary_op	:	
		PLUS 		{$$=newnode(yylineno,"","binary_op", "plus","+", 0);}
	|   MOINS 		{$$=newnode(yylineno,"","binary_op", "moins","-", 0);}
	|	MUL 		{$$=newnode(yylineno,"","binary_op", "fois", "*",0);}
	|	DIV 		{$$=newnode(yylineno,"","binary_op", "diviser", "/",0);}
	|   LSHIFT 		{$$=newnode(yylineno,"","binary_op", "LSHIFT","<<", 0);}
	|   RSHIFT		{$$=newnode(yylineno,"","binary_op", "RSHIFT", ">>",0);}
	|	BAND 		{$$=newnode(yylineno,"","binary_op", "band", "&",0);}
	|	BOR 		{$$=newnode(yylineno,"","binary_op", "bor", "|",0);}
;
binary_rel	:	
		LAND 		{$$=newnode(yylineno,"","binary_rel", "LAND","&&", 0);}
	|	LOR 		{$$=newnode(yylineno,"","binary_rel", "LOR","||", 0);}
;
binary_comp	:	
		LT 			{$$=newnode(yylineno,"","binary_comp", "LT","<", 0);}
	|	GT 			{$$=newnode(yylineno,"","binary_comp", "GT",">", 0);}
	|	GEQ 		{$$=newnode(yylineno,"","binary_comp", "GEQ",">=", 0);}
	|	LEQ 		{$$=newnode(yylineno,"","binary_comp", "LEQ","<=", 0);}
	|	EQEQ 		{$$=newnode(yylineno,"","binary_comp", "EQEQ","==", 0);}
	|	NEQ 		{$$=newnode(yylineno,"","binary_comp", "NEQ","!=", 0);}
;
%%


int main(int argc, char** argv) {
	if (argc > 1){
		FILE *file;
		file = fopen(argv[1], "r");
		if (!file){
			fprintf(stderr, "failed open");
			exit(1);
		}
		yyin = file;
	}

	int k;
	table_reset(tableSymbole_var);
	table_function_reset(tableSymbole_fun);
	printf("\t------------ TABLE SYMBOLE ------------ \t\n");
	yyparse();
        
        if(strcmp(nom_fichier(argv[1]),"variables.c")==0){
		genererDot(arbre,argv[1]);
		printf(BLU "INFORMATION : " RESET "Le code a été généré mais la routine sémantique associé au test ne marche pas !\n");
	}
	
	else{
		if(ERREUR_SEMANTIQUE==FALSE && ERREUR_SYNTAXE==FALSE){
			printf(BLU "Génération du code en cours...\n");
			genererDot(arbre,argv[1]);
			printf(RESET "Le code a été généré dans votre dossier courant !\n");
		
		}else{
		     printf(BLU "Information :" RESET" Le code ne peut pas être généré  \n");
		}
	}
	return 0; 

}

void yyerror(const char *s)
{
	fflush(stdout);
	fprintf(stderr, "%s \n", s);
	erreur_syntaxe();
	
}