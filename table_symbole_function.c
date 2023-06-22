#include "table_symbole_function.h"
#include "table_symbole.c"
#define RED  "\x1B[31m"
#define RESET "\x1B[0m"
#define BLU   "\x1B[34m"


void table_function_reset(table_function** tab_fun){
    for (int i = 0; i < TAILLE_TABLE_FUNCTION; i++){
        tab_fun[i] = NULL;
    }
    tab_fun = NULL;
}

table_function* insert_table_function(table_function** table_fun, char *typeFunction, char *nom_function) {

    int h;
    table_function *s;
    table_function *precedent;

    if (find_function_type(table_fun, typeFunction, nom_function) != NULL){
        fprintf(stderr,RED "Erreur " RESET "La fonction %s est déjà défini dans la table !\n", nom_function);
	    return NULL;
    }

    h = hash_function(nom_function);
    s = table_fun[h];
    
    precedent = NULL;

    while (s != NULL){
        if (strcmp(s->nom_function, nom_function) == 0){ // cette declaration de function existe deja
            return s;
        }
        precedent = s;
        s = s->suivant;
    }

    if (precedent == NULL){ // pas des declarations de function pour ce hash

        table_fun[h] = (table_function*) malloc(sizeof(table_function)); // cast de table_function* puisque malloc returne un void
        s = table_fun[h];

    }

    else {
        precedent->suivant = (table_function*) malloc(sizeof(table_function));
        s = precedent->suivant;
    }
    s->nom_function = strdup(nom_function);
    s->typeFunction = strdup(typeFunction);
    s->suivant = NULL;
    return s;
}

int find_function(table_function** table_fun, char *nom_fonction){
    int h = hash_function(nom_fonction);
    table_function* element = table_fun[h];
    while (element != NULL){
        if (strcmp (element->nom_function, nom_fonction) == 0){
            return TRUE;
        }
        element = element->suivant;
    }
    return FALSE;
}

table_function* find_function_type(table_function** table_fun, char* typeFunction, char* nom){
    int h = hash_function(nom);
    table_function* element = table_fun[h];

    while (element != NULL){
        if (strcmp (element->nom_function, nom) == 0 && strcmp(element->typeFunction, typeFunction) == 0){
            return element;
        }
        element = element->suivant;
    }
    return NULL;

}

void display_function(table_function** table_fun, char *nom_fonction) {
    int h = hash(nom_fonction);
    table_function* element = table_fun[h];
    while (element != NULL){
        if (strcmp(element->nom_function, nom_fonction) == 0){
            printf("Table %d : (  ", h);
            printf("fonction : %s ,  ",element->nom_function);
            printf("type : %s )\n",element->typeFunction);
        }
        element = element->suivant;
    }
}    

void insert_params(table_function** table_fun, char *nom_function, char* typeParam, char *param ) {
    int h = hash(nom_function);
    table_function* element = table_fun[h];

    while (element != NULL){
        if (strcmp (element->nom_function, nom_function) == 0){
            insert_table(element->tab_params, typeParam, param);
        }

        element = element->suivant;
    }

}

int find_param(table_function** table_fun, char *param) {
    table_function* element = NULL;
    
    for (int i = 0; i < TAILLE; i++){
        element = table_fun[i];
        
        while (element != NULL){ // parcours de la liste 
            if (find(element->tab_params, param) == TRUE) {
                return TRUE;
            } // tableau des symboles et un nom de parametre;
            element = element->suivant;
        }
    }
    return FALSE;
}

void display_function_param(table_function** table_fun, char *nom_fonction, char* param){
    int h = hash_function(nom_fonction);
    table_function* element = table_fun[h];
    
    while (element != NULL){
        if (strcmp(element->nom_function, nom_fonction) == 0 ){
            for (int j = 0; j < TAILLE; j++){
                printf("-> \t   (  parametre : %s , ", element->tab_params[j]->nom);
				printf(" type : %s )\n", element->tab_params[j]->type);
            }
        }
        element = element->suivant;
    }


}