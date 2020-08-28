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
[\'][^\\\"]*([\\][\\\"ntr][^\\\"]*)*[\']            {  return 'Cadena'; }
[\`][^\\\"]*([\\][\\\"ntr][^\\\"]*)*[\`]            {  return 'Cadena'; }


/*TIPOS DE DATOS*/

"number"                                            {  return 'T_Number';  }
"boolean"                                           {  return 'T_Boolean'; }
"string"                                            {  return 'T_String';  }
"type"                                              {  return 'T_Type';    }
"void"                                              {  return 'T_Void';    }                              

/*PALABRAS RESERVADAS*/

"let"                                               {  return 'R_Let';   }
"const"                                             {  return 'R_Const'; }
"Array"                                             {  return 'R_Array'; }                }
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

/*  EXPRESION */

"++"                                                {return 'OP_Incremento';}
"--"                                                {return 'OP_Decremento';}
"+"                                                 {return 'OP_Mas';}
"-"                                                 {return 'OP_Menos';}
"*"                                                 {return 'OP_Multiplicacion';}
"/"                                                 {return 'OP_Division';}
"**"                                                {return 'OP_Exponenciacion';}
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
%left 'OP_Potencia' 'OP_Modulo'
%left UMINUS PRUEBA
%start INICIO

%%
INICIO : CONT EOF{console.log($$);}
;

CONT: LISTA_CONTENIDO
    |
;

LISTA_CONTENIDO : LISTA_CONTENIDO CONTENIDO {$$ = $1 + $2}
                | CONTENIDO {$$=$1}
;

//aqui se agregara el resto de contenido que puede venir en un archivo
CONTENIDO : FUNCIONES
          | ESTRUCTURAS_DE_CONTROL
          | VARIABLES
;

FUNCIONES : R_Funcion Identificador S_ParentesisAbre PARAM S_ParentesisCierra S_LlaveAbre CONT S_LlaveCierra {$$ = $1 + $2 +$3 +$4 +$5 +$6 }
          | R_Funcion Identificador S_ParentesisAbre PARAM S_ParentesisCierra S_DosPuntos TIPOS_DE_DATO S_LlaveAbre CONT S_LlaveCierra {$$ = $1 + $2 +$3 +$4 +$5 +$6 }
          | R_Let Identificador S_Igual R_Funcion S_ParentesisAbre PARAM S_ParentesisCierra TIPAR_FUNCION S_LlaveAbre CONT S_LlaveCierra S_PuntoComa {$$ = $1 + $2 +$3 +$4 +$5 +$6 +$7+$8+$9}
          | R_Const Identificador S_Igual R_Funcion S_ParentesisAbre PARAM S_ParentesisCierra TIPAR_FUNCION S_LlaveAbre CONT S_LlaveCierra S_PuntoComa
;

ESTRUCTURAS_DE_CONTROL: LISTADO_IF ELSE
                      | SWITCH
                      | IMPRIMIR
                      | WHILE
                      | DO_WHILE
                      | R_Break S_PuntoComa
                      | R_Continue S_PuntoComa
                      | R_Return S_PuntoComa
;
/*---------------------------------------------IF---------------------------------------------------------*/
LISTADO_IF : LISTADO_IF R_Else IF
           | IF
;

IF : R_If S_ParentesisAbre EXPRESION_G S_ParentesisCierra S_LlaveAbre CONT S_LlaveCierra
;

ELSE : R_Else S_LlaveAbre CONT S_LlaveCierra
     |
;

/*---------------------------------------------SWITCH---------------------------------------------------------*/
SWITCH : R_Switch S_ParentesisAbre EXPRESION_G S_ParentesisCierra S_LlaveAbre CASE DEFINIR_DEFAULT S_LlaveCierra
;

CASE : LISTA_CASE
     |
;

LISTA_CASE: LISTA_CASE DEFINIR_CASE
          | DEFINIR_CASE
;

DEFINIR_CASE:R_Case EXPRESION_G S_DosPuntos CONT
;

DEFINIR_DEFAULT: R_Default S_DosPuntos CONT
               |
;
/*---------------------------------------------IMPRIMIR---------------------------------------------------------*/
IMPRIMIR: R_Console S_Punto R_Log S_ParentesisAbre FUNC S_ParentesisCierra S_PuntoComa
;

FUNC: EXPRESION_G
    |
;
/*---------------------------------------------WHILE---------------------------------------------------------*/
WHILE: R_While S_ParentesisAbre EXPRESION_G S_ParentesisCierra S_LlaveAbre CONT S_LlaveCierra
;
/*---------------------------------------------DO-WHILE---------------------------------------------------------*/
DO_WHILE: R_Do S_LlaveAbre CONT S_LlaveCierra R_While S_ParentesisAbre EXPRESION_G S_ParentesisCierra S_PuntoComa
;
/*---------------------------------------------VARIABLES---------------------------------------------------------*/
VARIABLES : R_Let Identificador COMPLEMENTO_VARIABLES S_PuntoComa
          | R_Const Identificador COMPLEMENTO_VARIABLES S_PuntoComa
;

COMPLEMENTO_VARIABLES : S_DosPuntos TIPOS_DE_DATO
                      | S_DosPuntos TIPOS_DE_DATO S_Igual EXPRESION_G
                      | S_Igual EXPRESION_G
                      |
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
/*---------------------------------------------TIPOS DE DATO---------------------------------------------------------*/
TIPOS_DE_DATO : T_Number
              | T_Boolean
              | T_String
              | T_Void
;
//agrega tipos de dato a funciones anonimas
TIPAR_FUNCION : S_DosPuntos TIPOS_DE_DATO
              |
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
    | EXPRESION_G OP_Potencia EXPRESION_G                                                        { $$ = $1 + $2 + $3; }
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
    | S_ParentesisAbre EXPRESION_G S_ParentesisCierra                                            { $$ = $1 + $2 + $3; }
    | Identificador
    | Cadena
;



