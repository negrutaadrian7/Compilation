#define RED  "\x1B[31m"
#define RESET "\x1B[0m"
#define BLU   "\x1B[34m"

int hash(char *nom){
    int i, r;
    int taille = strlen(nom);
    r = 0;
    for( i = 0; i < taille; i++)
        r = (((r << 8)+nom[i])%TAILLE_TABLE_VARIABLE);
    return r;
}

void table_reset (table_symbole_variable** tab){
    for (int i = 0; i < 103; i++){
        free(tab[i]);
    }
    free(tab);
}

table_symbole_variable* insert_table (table_symbole_variable** tab, char *nom, char *type){
    int h;
    table_symbole_variable *s;
    table_symbole_variable *precedent;

    h = hash(nom);
    s = tab[h];
    
    precedent = NULL;

    if (find (tab, nom) != FALSE){
        fprintf(stderr, RED "Erreur : " RESET " La variable %s est déjà défini dans la table !\n",nom); 
        return NULL;
    }

    if (type == "void"){
        fprintf(stderr,RED "Erreur : " RESET " La variable %s ne peut pas être de type %s !\n",nom,type); 
        return NULL;
    }

    while (s != NULL){
        if (strcmp (s->nom, nom) == 0){
            return NULL;
        }
    }

    if (precedent == NULL){
        tab[h] = (table_symbole_variable*) malloc(sizeof(table_symbole_variable));
        s = tab[h];
    }

    else {
        precedent->suivant = (table_symbole_variable*) malloc (sizeof(table_symbole_variable));
        s = precedent->suivant;
    }

    s->nom = strdup(nom);
    s->type = strdup(type);
    s->suivant = NULL;
    return s;

}

int find(table_symbole_variable** tab, char *nom) {
    int h = hash(nom);
    table_symbole_variable* el = tab[h];
    while(el != NULL){
        if (strcmp(el->nom, nom) == 0){
            return TRUE;
        }
    }
    return FALSE;
}

char* find_type(table_symbole_variable** tab, char *nom){
    int h = hash(nom);
    table_symbole_variable* el = tab[h];
    while (el != NULL){
        if (strcmp(el->nom, nom) == 0){
            return el->type;
        }
    }
    return NULL; 
}

void display_variables (table_symbole_variable** tab, char *nom){

    int h = hash(nom);
    table_symbole_variable* element = tab[h];

    while (element != NULL){
        if (strcmp(element->nom, nom) == 0){
            printf("Table %d : ( ", h);
            printf("Variable : %s , ", element->nom);
            printf("Type : %s , ", element->type);
            printf(")\n");
        }
    }

}

int hash_function(char* nom){
     int i = 0, nombreHache = 0;

    for (i = 0 ; nom[i] != '\0' ; i++)
    {
        nombreHache += nom[i] ;
	
    }
    nombreHache %= 100;
    

    return nombreHache;

};