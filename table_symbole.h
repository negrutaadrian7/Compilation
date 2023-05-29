#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TRUE 1
#define FALSE 0
#define TAILLE_TABLE_VARIABLE 103

typedef struct _table_variable {
    char *nom;
    char *type;

    struct _table_variable *suivant;
} table_symbole_variable;

int hash(char *nom);

void table_reset (table_symbole_variable** tab);

table_symbole_variable* insert_table(table_symbole_variable** tab, char *nom, char *type);

int find(table_symbole_variable** tab, char *nom);

char* find_type (table_symbole_variable** tab, char *nom);

void display_variables(table_symbole_variable** tab, char *nom);
