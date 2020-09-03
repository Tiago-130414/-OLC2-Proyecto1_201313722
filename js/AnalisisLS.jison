/* descripcion: ANALIZADOR DEL LENGUAJE JAVA */
// segmento de codigo, importaciones y todo dentro de 

/*  Directivas lexicas, expresiones regulares ,Analisis Lexico */
%lex
%options flex case-sensitive
%options yylineno
%locations
%%
\s+                   /* salta espacios en blanco */
"//".*               {/* comentario simple*/}
[/][*][^*]*[*]+([^/*][^*]*[*]+)*[/] {/*comentario multilinea*/}

/*  CADENAS  */
[\"][^\\\"]*([\\][\\\"ntr][^\\\"]*)*[\"]            {  return 'Cadena'; }
[\'][^\\\']*([\\][\\\'ntr][^\\\']*)*[\']            {  return 'Cadena'; }
[\`][^\\\`]*([\\][\\\`ntr][^\\\`]*)*[\`]            {  return 'Cadena'; }


/*TIPOS DE DATOS*/

"number"                                            {  return 'T_Number';  }
"boolean"                                           {  return 'T_Boolean'; }
"string"                                            {  return 'T_String';  }
"type"                                              {  return 'T_Type';    }
"void"                                              {  return 'T_Void';    }                              

/*PALABRAS RESERVADAS*/

"let"                                               {  return 'R_Let';   }
"const"                                             {  return 'R_Const'; }
"Array"                                             {  return 'R_Array'; }
"push"                                              {  return 'R_Push';  }
"pop"                                               {  return 'R_Pop';   }
"length"                                            {  return 'R_Length';}
"function"                                          {  return 'R_Funcion';}

/*ESTRUCTURAS DE CONTROL*/
"if"                                                {return 'R_If';}
"else"                                              {return 'R_Else';}
"switch"                                            {return 'R_Switch';}
"case"                                              {return 'R_Case';}
"default"                                           {return 'R_Default';}
"for"                                               {return 'R_For';}
"in"                                                {return 'R_In';}
"of"                                                {return 'R_Of';}
"while"                                             {return 'R_While';}
"do"                                                {return 'R_Do';}
"break"                                             {return 'R_Break';}
"continue"                                          {return 'R_Continue';}
"return"                                            {return 'R_Return';}
"console"                                           {return 'R_Console';}
"log"                                               {return 'R_Log';}
"true"                                              {return 'R_True';}    
"false"                                             {return 'R_False';}
"undefined"                                         {return 'R_Undefined';}

/*  EXPRESION */

"++"                                                {return 'OP_Incremento';}
"--"                                                {return 'OP_Decremento';}
"+"                                                 {return 'OP_Mas';}
"-"                                                 {return 'OP_Menos';}
"**"                                                {return 'OP_Exponenciacion';}
"*"                                                 {return 'OP_Multiplicacion';}
"/"                                                 {return 'OP_Division';}
"%"                                                 {return 'OP_Modulo';}

/* OPERADORES RELACIONALES*/

"<="	                                            {return 'REL_MenorIgualQue';}
">="		                                        {return 'REL_MayorIgualQue';}
"=="		                                        {return 'REL_IgualIgual';}
"="                                                 {return 'S_Igual';}
"!="		                                        {return 'REL_Distinto';}
"<"			                                        {return 'REL_MenorQue';}
">"			                                        {return 'REL_MayorQue';}

/*OPERADORES LOGICOS*/

"!"			                                        {return 'LOG_Not';}
"&&"		                                        {return 'LOG_Concatenar';}
"||"		                                        {return 'LOG_OR';}

/*  SIMBOLO */

":"			                                        {return 'S_DosPuntos';}
";"			                                        {return 'S_PuntoComa';}
"{"			                                        {return 'S_LlaveAbre';}
"}"			                                        {return 'S_LlaveCierra';}
"("			                                        {return 'S_ParentesisAbre';}
")"			                                        {return 'S_ParentesisCierra';}
"."                                                 {return 'S_Punto';}
"\'"                                                {return 'S_ComillaSimple';}
","                                                 {return 'S_Coma';}
"\""                                                {return 'S_ComillaDoble';}
"?"                                                 {return 'S_Interrogacion';}
"["                                                 {return 'S_CorcheteAbre';}
"]"                                                 {return 'S_CorcheteCierra';}

/*  NUMEROS */
[0-9]+("."[0-9]+)?\b                                {return 'Decimal';}
[0-9]+\b                                            {return 'Entero';}

/*  IDENTIFICADORES */
([a-zA-Z_])[a-zA-Z0-9_]*                            {return 'Identificador';}
<<EOF>>                                             {  return 'EOF'; }
.                                                   {console.error("error lexico: " + yytext)}
/lex
//PRECEDENCIA DE OPERADORES
//prescedencia operadores logicos
%left 'LOG_Concatenar' 'LOG_OR'
//prescedencia operadores relcionales
%left 'REL_IgualIgual' 'REL_Distinto' 'REL_MayorIgualQue' 'REL_MayorQue' 'REL_MenorIgualQue' 'REL_MenorQue'
//prescedencia operadores aritmeticos
%left 'OP_Mas' 'OP_Menos'
%left 'OP_Multiplicacion' 'OP_Division' 
%left 'OP_Exponenciacion' 'OP_Modulo'
%left UMINUS PRUEBA
%start INICIO

%%
INICIO : CONT EOF{console.log($1);}
;
/*---------------------------------------------LISTA DE CONTENIDO GLOBAL---------------------------------------------------------*/
CONT: LISTA_CONTENIDO                                       {$$ = {Nombre:"CONT",vector:[$1]};}
    |                                                       {$$ = {Nombre:"CONT",vector:[]};}
;

LISTA_CONTENIDO : LISTA_CONTENIDO CONTENIDO                 {$1.vector.push($2); $$ = $1;}
                | CONTENIDO                                 {$$ = {Nombre:"LISTA_CONTENIDO",vector:[$1]};}
;

//CONTENIDO GLOBAL
CONTENIDO : FUNCIONES                                       {$$ = {Nombre:"CONTENIDO",vector:[$1]};}
          | ESTRUCTURAS_DE_CONTROL                          {$$ = {Nombre:"CONTENIDO",vector:[$1]};}
;
/*---------------------------------------------DEFINICION DE FUNCIONES---------------------------------------------------------*/
FUNCIONES : R_Funcion Identificador S_ParentesisAbre PARAM S_ParentesisCierra S_LlaveAbre CONT S_LlaveCierra                                            {$$ = {Nombre:"FUNCIONES",vector:[$2,$4,$7]};}
          | R_Funcion Identificador S_ParentesisAbre PARAM S_ParentesisCierra S_DosPuntos TIPOS_DE_DATO S_LlaveAbre CONT S_LlaveCierra                  {$$ = {Nombre:"FUNCIONES",vector:[$2,$4,$7,$9]};}
          | R_Let Identificador S_Igual R_Funcion S_ParentesisAbre PARAM S_ParentesisCierra TIPAR_FUNCION S_LlaveAbre CONT S_LlaveCierra S_PuntoComa    {$$ = {Nombre:"FUNCIONES",vector:[$2,$6,$8,$10]};}
          | R_Const Identificador S_Igual R_Funcion S_ParentesisAbre PARAM S_ParentesisCierra TIPAR_FUNCION S_LlaveAbre CONT S_LlaveCierra S_PuntoComa  {$$ = {Nombre:"FUNCIONES",vector:[$2,$4,$8,$10]};}
;
/*---------------------------------------------LISTADO DE ESTRUCTURAS DE CONTROL---------------------------------------------------------*/
EDD:LISTADO_ESTRUCTURAS                                                 {$$ = {Nombre:"EDD",vector:[$1]};}
   |                                                                    {$$ = {Nombre:"EDD",vector:[]};}
;

LISTADO_ESTRUCTURAS : LISTADO_ESTRUCTURAS ESTRUCTURAS_DE_CONTROL        {$1.vector.push($2); $$ = $1;}
                    | ESTRUCTURAS_DE_CONTROL                            {$$ = {Nombre:"LISTADO_ESTRUCTURAS",vector:[$1]};}
;

ESTRUCTURAS_DE_CONTROL: VARIABLES                                       {$$ = {Nombre:"ESTRUCTURAS_DE_CONTROL",vector:[$1]};}
                      | ASIGNACION                                      {$$ = {Nombre:"ESTRUCTURAS_DE_CONTROL",vector:[$1]};}
                      | LISTADO_IF ELSE                                 {$1.vector.push($2); $$ = $1;}
                      | SWITCH                                          {$$ = {Nombre:"ESTRUCTURAS_DE_CONTROL",vector:[$1]};}
                      | IMPRIMIR                                        {$$ = {Nombre:"ESTRUCTURAS_DE_CONTROL",vector:[$1]};}
                      | WHILE                                           {$$ = {Nombre:"ESTRUCTURAS_DE_CONTROL",vector:[$1]};}
                      | DO_WHILE                                        {$$ = {Nombre:"ESTRUCTURAS_DE_CONTROL",vector:[$1]};}
                      | FOR                                             {$$ = {Nombre:"ESTRUCTURAS_DE_CONTROL",vector:[$1]};}
                      | FOR_OF                                          {$$ = {Nombre:"ESTRUCTURAS_DE_CONTROL",vector:[$1]};}
                      | FOR_IN                                          {$$ = {Nombre:"ESTRUCTURAS_DE_CONTROL",vector:[$1]};}
                      | SENTENCIAS_TRANSFERENCIA                        {$$ = {Nombre:"ESTRUCTURAS_DE_CONTROL",vector:[$1]};}
                      | LLAMADA_FUNC                                    {$$ = {Nombre:"ESTRUCTURAS_DE_CONTROL",vector:[$1]};}
                      | TYPES                                           {$$ = {Nombre:"ESTRUCTURAS_DE_CONTROL",vector:[$1]};}

;
/*--------------------------------------------- SENTENCIAS DE TRANSFERENCIA ---------------------------------------------------------*/

SENTENCIAS_TRANSFERENCIA : R_Break S_PuntoComa
                         | R_Continue S_PuntoComa
                         | R_Return S_PuntoComa
                         | R_Return EXPRESION_G S_PuntoComa
;

/*--------------------------------------------- LISTADO IF---------------------------------------------------------*/
LISTADO_IF : LISTADO_IF R_Else IF                                       {$3.Nombre = "ELSE_IF";$1.vector.push($3); $$ = $1;}
           | IF                                                         {$$ = {Nombre:"LISTADO_IF",vector:[$1]};}
;

IF : R_If S_ParentesisAbre EXPRESION_G S_ParentesisCierra S_LlaveAbre EDD S_LlaveCierra     {$$ = {Nombre:"IF",vector:[$3,$6]};}
;

ELSE : R_Else S_LlaveAbre EDD S_LlaveCierra                                                 {$$ = {Nombre:"ELSE",vector:[$3]};}
     |                                                                                      {$$ = {Nombre:"VACIO",vector:[]};}
;

/*---------------------------------------------SWITCH---------------------------------------------------------*/
SWITCH : R_Switch S_ParentesisAbre EXPRESION_G S_ParentesisCierra S_LlaveAbre CASE DEFINIR_DEFAULT S_LlaveCierra
;

/*---------------------------------------------LISTADO DE CASE---------------------------------------------------------*/

CASE : LISTA_CASE
     |
;

LISTA_CASE: LISTA_CASE DEFINIR_CASE
          | DEFINIR_CASE
;

DEFINIR_CASE:R_Case EXPRESION_G S_DosPuntos EDD
;
/*---------------------------------------------DEFINICION DE DEFAULT---------------------------------------------------------*/

DEFINIR_DEFAULT: R_Default S_DosPuntos EDD
               |
;
/*---------------------------------------------IMPRIMIR---------------------------------------------------------*/
IMPRIMIR: R_Console S_Punto R_Log S_ParentesisAbre FUNC S_ParentesisCierra S_PuntoComa                      {$$ = {Nombre:"IMPRIMIR",vector:[$5]};}
;

FUNC: EXPRESION_G
    |
;
/*---------------------------------------------WHILE---------------------------------------------------------*/
WHILE: R_While S_ParentesisAbre EXPRESION_G S_ParentesisCierra S_LlaveAbre EDD S_LlaveCierra
;
/*---------------------------------------------DO-WHILE---------------------------------------------------------*/
DO_WHILE: R_Do S_LlaveAbre EDD S_LlaveCierra R_While S_ParentesisAbre EXPRESION_G S_ParentesisCierra S_PuntoComa
;

/*---------------------------------------------FOR---------------------------------------------------------*/
FOR : R_For S_ParentesisAbre CONT_FOR EXPRESION_G S_PuntoComa FIN_FOR S_ParentesisCierra S_LlaveAbre EDD S_LlaveCierra { $$ = $1 + $2 + $3 + $4 + $5 + $6 + $7 + $8 + $9 + $10; } 
;

CONT_FOR
    : R_Let Identificador S_DosPuntos TIPOS_DE_DATO S_Igual EXPRESION_G S_PuntoComa
    | R_Let Identificador S_Igual EXPRESION_G S_PuntoComa
    | Identificador S_PuntoComa
    | Identificador S_Igual EXPRESION_G S_PuntoComa
;

FIN_FOR
    : Identificador S_Igual EXPRESION_G                                                { $$ = $1 + $2 + $3; }
    | Identificador OP_Incremento
    | OP_Incremento Identificador
    | Identificador OP_Decremento
    | OP_Decremento IdentificadorG                                                                      
    ;
/*---------------------------------------------FOR IN---------------------------------------------------------*/

FOR_IN: R_For S_ParentesisAbre CONT_FOR_IN S_ParentesisCierra S_LlaveAbre EDD S_LlaveCierra
;

CONT_FOR_IN : R_Const Identificador R_In Identificador
            | R_Let Identificador R_In Identificador
            | Identificador R_In Identificador
;


/*---------------------------------------------FOR OF---------------------------------------------------------*/
FOR_OF: R_For S_ParentesisAbre CONT_FOR_OF S_ParentesisCierra S_LlaveAbre EDD S_LlaveCierra
;

CONT_FOR_OF : R_Const Identificador R_Of Identificador
            | R_Let Identificador R_Of Identificador
            | Identificador R_Of Identificador
;

/*---------------------------------------------ASIGNACION VARIABLES---------------------------------------------------------*/

ASIGNACION : ATRIBUTOS S_Igual LISTA_DE_ASIGNACIONES S_PuntoComa
           //incrementos 
           | ATRIBUTOS OP_Incremento COMPLETAR_ASIGNACION S_PuntoComa
           | OP_Incremento ATRIBUTOS COMPLETAR_ASIGNACION S_PuntoComa
           | ATRIBUTOS OP_Decremento COMPLETAR_ASIGNACION S_PuntoComa
           | OP_Decremento ATRIBUTOS COMPLETAR_ASIGNACION S_PuntoComa
           | ATRIBUTOS S_Punto R_Push S_ParentesisAbre LISTA_DE_ASIGNACIONES S_ParentesisCierra  S_PuntoComa
;

COMPLETAR_ASIGNACION : LISTADO_ASIGNACION
                      |
;

LISTADO_ASIGNACION: LISTADO_ASIGNACION  CONTENIDO_ASIGNACION
                  | CONTENIDO_ASIGNACION
;

CONTENIDO_ASIGNACION: S_Coma Identificador S_Igual EXPRESION_G
                    | S_Coma Identificador OP_Incremento
                    | S_Coma OP_Incremento Identificador
                    | S_Coma Identificador OP_Decremento
                    | S_Coma OP_Decremento Identificador
;

LISTA_DE_ASIGNACIONES : EXPRESION_G
                      | S_CorcheteAbre CONT_ASIG_ARRAY S_CorcheteCierra 
                      | S_LlaveAbre LISTA_DECLARACION_TYPES S_LlaveCierra
;




/*---------------------------------------------LISTA DE ASIGNACION ARRAY DENTRO DE ARRAY---------------------------------------------------------*/
CONT_ASIG_ARRAY: LISTA_ASIGN_ARRAY
               |
;

LISTA_ASIGN_ARRAY: LISTA_ASIGN_ARRAY S_Coma CONT_ARRAY_ASIGN_VV
                 | CONT_ARRAY_ASIGN_VV
;   

CONT_ARRAY_ASIGN_VV: EXPRESION_G 
                   | S_CorcheteAbre CONT_ASIG_ARRAY S_CorcheteCierra
                   | S_LlaveAbre LISTA_DECLARACION_TYPES S_LlaveCierra
;


/*---------------------------------------------VARIABLES---------------------------------------------------------*/

VARIABLES : R_Let LISTADO_VAR S_PuntoComa
          | R_Const LISTADO_VAR S_PuntoComa
;

/*---------------------------------------------LISTADO VARIABLES---------------------------------------------------------*/

LISTADO_VAR : LISTADO_VAR S_Coma CONT_VAR
            | CONT_VAR
;
/*--------------------------------------------- DEFINICION DE VARIABLES---------------------------------------------------------*/

CONT_VAR: Identificador //declaracion de variable solo id
        | Identificador S_DosPuntos TIPOS_DE_DATO  //declaracion de variable con tipo de dato
        | Identificador S_DosPuntos TIPOS_DE_DATO S_Igual EXPRESION_G   //declaracion de variable con tipo y asignacion de valor
        | Identificador S_Igual EXPRESION_G //declaracion de variable con asignacion de valor


        | Identificador S_Igual S_CorcheteAbre CONT_ASIG_ARRAY S_CorcheteCierra //array
        | Identificador S_DosPuntos TIPOS_DE_DATO S_CorcheteAbre S_CorcheteCierra //array
        | Identificador S_DosPuntos TIPOS_DE_DATO S_CorcheteAbre S_CorcheteCierra S_Igual S_CorcheteAbre CONT_ASIG_ARRAY S_CorcheteCierra //array


        | Identificador S_DosPuntos TIPOS_DE_DATO S_Igual S_LlaveAbre LISTA_DECLARACION_TYPES S_LlaveCierra //types
        | Identificador S_Igual S_LlaveAbre LISTA_DECLARACION_TYPES S_LlaveCierra //types
;


/*--------------------------------------------- CONTENIDO ARRAY ---------------------------------------------------------*/

CONTENIDO_ARRAY: LISTADO_ARRAY
                |
;

LISTADO_ARRAY: LISTADO_ARRAY S_Coma CONT_ARR
            | CONT_ARR
;

CONT_ARR: S_LlaveAbre LISTA_DECLARACION_TYPES S_LlaveCierra
        | EXPRESION_G
;

/*---------------------------------------------LLAMADAS A FUNCION---------------------------------------------------------*/

LLAMADA_FUNC
    : Identificador S_ParentesisAbre PARAMETROS_FUNC S_ParentesisCierra S_PuntoComa {$$ = $1 + $2 + $3 + $4 + $5;}
    | ATRIBUTOS S_Punto R_Pop S_ParentesisAbre S_ParentesisCierra S_PuntoComa {$$ = $1 + $2 + $3 + $4 + $5;}
;

PARAMETROS_FUNC
    : PARAMETROS_FUNC S_Coma EXPRESION_G {$$ = $1 + $2 + $3;}
    | EXPRESION_G
    | {$$='';}
;

/*---------------------------------------------PARAMETROS---------------------------------------------------------*/
PARAM: LISTA_PARAMETROS
     |
;

LISTA_PARAMETROS : LISTA_PARAMETROS S_Coma PARAMETROS  {$$ = $1 + $2}
                 | PARAMETROS {$$=$1}              
;

PARAMETROS : Identificador S_DosPuntos TIPOS_DE_DATO {$$ = $1 + $2 +$3}
           | Identificador S_DosPuntos TIPOS_DE_DATO S_Igual EXPRESION_G {$$ = $1 + $2 +$3 +$4}
           | Identificador S_Interrogacion S_DosPuntos TIPOS_DE_DATO {$$ = $1 + $2 +$3 +$4}
;
/*---------------------------------------------TYPES---------------------------------------------------------*/


TYPES: T_Type Identificador S_Igual S_LlaveAbre LISTA_TYPES FIN_TYPES
;

LISTA_TYPES: LISTA_TYPES SEPARADOR CONTENIDO_TYPES
           | CONTENIDO_TYPES
;

CONTENIDO_TYPES : Identificador S_DosPuntos TIPOS_DE_DATO
                | Identificador S_DosPuntos Identificador S_CorcheteAbre S_CorcheteCierra
;

SEPARADOR : S_Coma
          | S_PuntoComa
;

FIN_TYPES: S_LlaveCierra S_PuntoComa
         | S_LlaveCierra
;

/*---------------------------------------------DECLARACION DE TYPES---------------------------------------------------------*/
LISTA_DECLARACION_TYPES: LISTA_DECLARACION_TYPES SEPARADOR_DECLARACION_TYPES CONTENIDO_DECLARACION_TYPES
                        | CONTENIDO_DECLARACION_TYPES
;

CONTENIDO_DECLARACION_TYPES : Identificador S_DosPuntos LISTA_DE_ASIGNACIONES
;

SEPARADOR_DECLARACION_TYPES : S_Coma
                            | S_PuntoComa
;

/*---------------------------------------------TIPOS DE DATO---------------------------------------------------------*/
TIPOS_DE_DATO : T_Number
              | T_Boolean
              | T_String
              | T_Void
              | Identificador
;
//agrega tipos de dato a funciones anonimas
TIPAR_FUNCION : S_DosPuntos TIPOS_DE_DATO
              |
;
/*---------------------------------------------ACCEDER A ATRIBUTOS---------------------------------------------------------*/

 ATRIBUTOS: ATRIBUTOS S_Punto CONT_ATRIBUTOS
          | CONT_ATRIBUTOS
 ;

 CONT_ATRIBUTOS:  Identificador S_CorcheteAbre EXPRESION_G S_CorcheteCierra
               |  Identificador
;

/*---------------------------------------------EXPRESIONES---------------------------------------------------------*/
EXPRESION_G 
    : EXPRESION_G LOG_Concatenar EXPRESION_G                                                     { $$ = $1 + $2 + $3; }
    | EXPRESION_G LOG_OR EXPRESION_G                                                             { $$ = $1 + $2 + $3; }
    | EXPRESION_G REL_IgualIgual EXPRESION_G                                                     { $$ = $1 + $2 + $3; }   
    | EXPRESION_G REL_MayorIgualQue EXPRESION_G                                                  { $$ = $1 + $2 + $3; }
    | EXPRESION_G REL_MayorQue EXPRESION_G                                                       { $$ = $1 + $2 + $3; }
    | EXPRESION_G REL_MenorIgualQue EXPRESION_G                                                  { $$ = $1 + $2 + $3; }
    | EXPRESION_G REL_MenorQue EXPRESION_G                                                       { $$ = $1 + $2 + $3; }
    | EXPRESION_G REL_Distinto EXPRESION_G                                                       { $$ = $1 + $2 + $3; }       
    | EXPRESION_G OP_Mas EXPRESION_G                                                             { $$ = $1 + $2 + $3; }
    | EXPRESION_G OP_Menos EXPRESION_G                                                           { $$ = $1 + $2 + $3; }
    | EXPRESION_G OP_Multiplicacion EXPRESION_G                                                  { $$ = $1 + $2 + $3; }
    | EXPRESION_G OP_Division EXPRESION_G                                                        { $$ = $1 + $2 + $3; }   
    | EXPRESION_G OP_Exponenciacion EXPRESION_G                                                  { $$ = $1 + $2 + $3; }
    | EXPRESION_G OP_Modulo EXPRESION_G                                                          { $$ = $1 + $2 + $3; }
    | CONTENIDO_EXPRESION OP_Decremento %prec PRUEBA                                             { $$ = $1 + $2; }
    | CONTENIDO_EXPRESION OP_Incremento %prec PRUEBA                                             { $$ = $1 + $2; }
    | OP_Decremento CONTENIDO_EXPRESION                                                          { $$ = $1 + $2;}
    | OP_Incremento CONTENIDO_EXPRESION                                                          { $$ = $1 + $2;}
    | OP_Menos  CONTENIDO_EXPRESION     %prec UMINUS                                             { $$ = $1 + $2; }
    | LOG_Not   CONTENIDO_EXPRESION     %prec UMINUS                                             { $$ = $1 + $2; }
    | CONTENIDO_EXPRESION
;

 CONTENIDO_EXPRESION
    : Entero
    | Decimal
    | R_True
    | R_False
    | Identificador S_ParentesisAbre S_ParentesisCierra                                          { $$ = $1 + $2 + $3; }
    | Identificador S_ParentesisAbre OPCIONAL S_ParentesisCierra                                 { $$ = $1 + $2 + $3 + $4; }
    | S_ParentesisAbre EXPRESION_G S_ParentesisCierra                                            { $$ = $1 + $2 + $3; }
    | Cadena
    | ATRIBUTOS
    | ATRIBUTOS S_Punto R_Length
    | ATRIBUTOS S_Punto R_Pop S_ParentesisAbre S_ParentesisCierra
; /*ATRIBUTOS CONTIENE ID Y VECTOR */

OPCIONAL 
    : OPCIONAL S_Coma EXPRESION_G                                                                { $$ = $1 + $2 + $3; }
    |EXPRESION_G    
; 