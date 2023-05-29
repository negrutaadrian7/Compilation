#include "table_symbole.h";
#define TAILLE 103

typedef struct table_function {

    char *nom_function;
    char *typeFunction;
    table_symbole_variable *tab_params[TAILLE];
    struct table_function *suivant;

} table_function;

void table_function_reset(table_function** table_fun);
table_function* insert_table_function(table_function** table_fun, char *typeFunction, char *nom_function);
int find_function(table_function** table_fun, char *nom_fonction);
void display_function(table_function** table_fun,char *nom_fonction);


void insert_params( table_function** table_fun, char* nom_function, char* typeParam, char* param);
int find_param(table_function** table_fun, char* param);
void display_function_param(table_function** table_fun,char *nom_fonction,char* param);



