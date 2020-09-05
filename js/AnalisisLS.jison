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
[0-9]+\b                                            {return 'Entero';}
[0-9]+("."[0-9]+)?\b                                {return 'Decimal';}


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
    |                                                       {$$ = undefined;}
;

LISTA_CONTENIDO : LISTA_CONTENIDO CONTENIDO                 {$$ = {Nombre: "LISTA_CONTENIDO" , vector:[$1,$2]};}
                | CONTENIDO                                 {$$ = {Nombre:"LISTA_CONTENIDO",vector:[$1]};}
;

//CONTENIDO GLOBAL
CONTENIDO : FUNCIONES                                       {$$ = {Nombre:"CONTENIDO",vector:[$1]};}
          | ESTRUCTURAS_DE_CONTROL                          {$$ = {Nombre:"CONTENIDO",vector:[$1]};}
;
/*---------------------------------------------DEFINICION DE FUNCIONES---------------------------------------------------------*/
FUNCIONES : R_Funcion Identificador S_ParentesisAbre PARAM S_ParentesisCierra S_LlaveAbre EDD S_LlaveCierra                                            {$$ = {Nombre:"FUNCIONES",vector:[$2,$4,$7]};}
          | R_Funcion Identificador S_ParentesisAbre PARAM S_ParentesisCierra S_DosPuntos TIPOS_DE_DATO S_LlaveAbre EDD S_LlaveCierra                  {$$ = {Nombre:"FUNCIONES",vector:[$2,$4,$7,$9]};}
          | R_Let Identificador S_Igual R_Funcion S_ParentesisAbre PARAM S_ParentesisCierra TIPAR_FUNCION S_LlaveAbre EDD S_LlaveCierra S_PuntoComa    {$$ = {Nombre:"FUNCIONES",vector:[$2,$6,$8,$10]};}
          | R_Const Identificador S_Igual R_Funcion S_ParentesisAbre PARAM S_ParentesisCierra TIPAR_FUNCION S_LlaveAbre EDD S_LlaveCierra S_PuntoComa  {$$ = {Nombre:"FUNCIONES",vector:[$2,$4,$8,$10]};}
;
/*---------------------------------------------LISTADO DE ESTRUCTURAS DE CONTROL---------------------------------------------------------*/
EDD:LISTADO_ESTRUCTURAS
   |                                                                    {$$ = undefined;}                     
;

LISTADO_ESTRUCTURAS : LISTADO_ESTRUCTURAS ESTRUCTURAS_DE_CONTROL        {$$ = {Nombre:"LISTADO_ESTRUCTURAS",vector:[$1,$2]};}
                    | ESTRUCTURAS_DE_CONTROL                            {$$ = {Nombre:"LISTADO_ESTRUCTURAS",vector:[$1]};}
;

ESTRUCTURAS_DE_CONTROL: VARIABLES                                       {$$ = {Nombre:"DECLARACION_VARIABLES",vector:[$1]};}
                      | ASIGNACION                                      {$$ = {Nombre:"ESTRUCTURAS_DE_CONTROL",vector:[$1]};}
                      | LISTADO_IF ELSE                                 {$$ = {Nombre:"CONDICIONAL",vector:[$1,$2]};}
                      | SWITCH                                          {$$ = {Nombre:"CONDICIONAL",vector:[$1]};}
                      | IMPRIMIR
                      | WHILE                                           {$$ = {Nombre:"CICLO",vector:[$1]};}
                      | DO_WHILE                                        {$$ = {Nombre:"CICLO",vector:[$1]};}
                      | FOR                                             {$$ = {Nombre:"CICLO",vector:[$1]};}
                      | FOR_OF                                          {$$ = {Nombre:"CICLO",vector:[$1]};}
                      | FOR_IN                                          {$$ = {Nombre:"CICLO",vector:[$1]};}
                      | SENTENCIAS_TRANSFERENCIA                        
                      | LLAMADA_FUNC                                    {$$ = {Nombre:"ESTRUCTURAS_DE_CONTROL",vector:[$1]};}
                      | TYPES                                           {$$ = {Nombre:"DECLARACION_TYPE",vector:[$1]};}

;
/*--------------------------------------------- SENTENCIAS DE TRANSFERENCIA ---------------------------------------------------------*/

SENTENCIAS_TRANSFERENCIA : R_Break S_PuntoComa                          {$$ = {Nombre:"BREAK",vector:undefined};}
                         | R_Continue S_PuntoComa                       {$$ = {Nombre:"CONTINUE",vector:undefined};}
                         | R_Return S_PuntoComa                         {$$ = {Nombre:"RETURN",vector:undefined};}
                         | R_Return EXPRESION_G S_PuntoComa             {$$ = {Nombre:"RETURN",vector:[$2]};}
;

/*--------------------------------------------- LISTADO IF---------------------------------------------------------*/
LISTADO_IF : LISTADO_IF R_Else IF                                                                                       {$$={Nombre:"ELSE_IF",vector : [$1].concat($3)};}
           | IF                                                                                                         {$$ = {Nombre:"IF",vector:$1};}
;

IF : R_If S_ParentesisAbre EXPRESION_G S_ParentesisCierra S_LlaveAbre EDD S_LlaveCierra                                 {$$ = [$3,$6];}
;

ELSE : R_Else S_LlaveAbre EDD S_LlaveCierra                                                                             {$$ = {Nombre:"ELSE",vector:[$3]};}
     |                                                                                                                  {$$ = undefined;}
;

/*---------------------------------------------SWITCH---------------------------------------------------------*/
SWITCH : R_Switch S_ParentesisAbre EXPRESION_G S_ParentesisCierra S_LlaveAbre CASE DEFINIR_DEFAULT S_LlaveCierra        {$$ = {Nombre:"SWITCH",vector:[$3,$6,$7]};}
;

/*---------------------------------------------LISTADO DE CASE---------------------------------------------------------*/

CASE : LISTA_CASE
     |                                                                                                                  {$$ = undefined;}
;

LISTA_CASE: LISTA_CASE DEFINIR_CASE                                                                                     {$$ = {Nombre:"LISTA_CASE",vector:[$1,$2]};}
          | DEFINIR_CASE                                                                                                {$$ = {Nombre:"LISTA_CASE",vector:[$1]};}
;

DEFINIR_CASE:R_Case EXPRESION_G S_DosPuntos EDD                                                                         {$$ = {Nombre:"CASE",vector:[$2,$4]};}
;
/*---------------------------------------------DEFINICION DE DEFAULT---------------------------------------------------------*/

DEFINIR_DEFAULT: R_Default S_DosPuntos EDD                                                                              {$$ = {Nombre:"DEFAULT",vector:[$3]};}
               |                                                                                                        {$$ = undefined;}
;
/*---------------------------------------------IMPRIMIR---------------------------------------------------------*/
IMPRIMIR: R_Console S_Punto R_Log S_ParentesisAbre FUNC S_ParentesisCierra S_PuntoComa                                  {$$ = {Nombre:"IMPRIMIR",vector:[$5]};}
;

FUNC: EXPRESION_G                                                                                                       {$$ = $1;}
    |                                                                                                                   {$$ = undefined;}
;
/*---------------------------------------------WHILE---------------------------------------------------------*/
WHILE: R_While S_ParentesisAbre EXPRESION_G S_ParentesisCierra S_LlaveAbre EDD S_LlaveCierra                            {$$ = {Nombre:"WHILE",vector:[$3,$6]};}           
;
/*---------------------------------------------DO-WHILE---------------------------------------------------------*/
DO_WHILE: R_Do S_LlaveAbre EDD S_LlaveCierra R_While S_ParentesisAbre EXPRESION_G S_ParentesisCierra S_PuntoComa        {$$ = {Nombre:"DO_WHILE",vector:[$3,$7]};}
;

/*---------------------------------------------FOR---------------------------------------------------------*/
FOR : R_For S_ParentesisAbre CONT_FOR EXPRESION_G S_PuntoComa FIN_FOR S_ParentesisCierra S_LlaveAbre EDD S_LlaveCierra  {$$ = {Nombre:"FOR",vector:[$3,$4,$6,$9]};}
;

CONT_FOR
    : R_Let Identificador S_DosPuntos TIPOS_DE_DATO S_Igual EXPRESION_G S_PuntoComa                                     {$$ = {Nombre:"INICIO_FOR",vector:[{Nombre: $1 , vector : undefined},{Nombre: $2 , vector : undefined},$4,$6]};}                          
    | R_Let Identificador S_Igual EXPRESION_G S_PuntoComa                                                               {$$ = {Nombre:"INICIO_FOR",vector:[{Nombre: $1 , vector : undefined},{Nombre: $2 , vector : undefined},$4]};}
    | Identificador S_PuntoComa                                                                                         {$$ = {Nombre:"INICIO_FOR",vector:[{Nombre: $1 , vector : undefined}]};}
    | Identificador S_Igual EXPRESION_G S_PuntoComa                                                                     {$$ = {Nombre:"INICIO_FOR",vector:[{Nombre: $1 , vector : undefined},$3]};}
;

FIN_FOR
    : Identificador S_Igual EXPRESION_G                                                                                 {$$ = {Nombre:"FIN_FOR",vector:[{Nombre: $1 , vector : undefined},$3]};}                                                                                  
    | Identificador OP_Incremento                                                                                       {$$ = {Nombre:"FIN_FOR",vector:[{Nombre: $1 , vector : undefined},{Nombre: $2 , vector : undefined}]};}
    | OP_Incremento Identificador                                                                                       {$$ = {Nombre:"FIN_FOR",vector:[{Nombre: $1 , vector : undefined},{Nombre: $2 , vector : undefined}]};}
    | Identificador OP_Decremento                                                                                       {$$ = {Nombre:"FIN_FOR",vector:[{Nombre: $1 , vector : undefined},{Nombre: $2 , vector : undefined}]};}
    | OP_Decremento IdentificadorG                                                                                      {$$ = {Nombre:"FIN_FOR",vector:[{Nombre: $1 , vector : undefined},{Nombre: $2 , vector : undefined}]};}                                                                  
    ;
/*---------------------------------------------FOR IN---------------------------------------------------------*/

FOR_IN: R_For S_ParentesisAbre CONT_FOR_IN S_ParentesisCierra S_LlaveAbre EDD S_LlaveCierra                             {$$ = {Nombre:"FOR_IN",vector:[$3,$6]};}      
;

CONT_FOR_IN : R_Const Identificador R_In Identificador                                                                  {$$ = {Nombre:"CONT_FOR_IN",vector:[{Nombre: $1 , vector : undefined},{Nombre: $2 , vector : undefined},{Nombre: $4 , vector : undefined}]};}
            | R_Let Identificador R_In Identificador                                                                    {$$ = {Nombre:"CONT_FOR_IN",vector:[{Nombre: $1 , vector : undefined},{Nombre: $2 , vector : undefined},{Nombre: $4 , vector : undefined}]};}
            | Identificador R_In Identificador                                                                          {$$ = {Nombre:"CONT_FOR_IN",vector:[{Nombre: $1 , vector : undefined},{Nombre: $3 , vector : undefined}]};}
;


/*---------------------------------------------FOR OF---------------------------------------------------------*/
FOR_OF: R_For S_ParentesisAbre CONT_FOR_OF S_ParentesisCierra S_LlaveAbre EDD S_LlaveCierra                             {$$ = {Nombre:"FOR_OF",vector:[$3,$6]};}
;

CONT_FOR_OF : R_Const Identificador R_Of Identificador                                                                  {$$ = {Nombre:"CONT_FOR_OF",vector:[{Nombre: $1 , vector : undefined},{Nombre: $2 , vector : undefined},{Nombre: $4 , vector : undefined}]};}
            | R_Let Identificador R_Of Identificador                                                                    {$$ = {Nombre:"CONT_FOR_OF",vector:[{Nombre: $1 , vector : undefined},{Nombre: $2 , vector : undefined},{Nombre: $4 , vector : undefined}]};}
            | Identificador R_Of Identificador                                                                          {$$ = {Nombre:"CONT_FOR_OF",vector:[{Nombre: $1 , vector : undefined},{Nombre: $3 , vector : undefined}]};}
;

/*---------------------------------------------ASIGNACION VARIABLES---------------------------------------------------------*/

ASIGNACION : ATRIBUTOS S_Igual LISTA_DE_ASIGNACIONES S_PuntoComa                                                        {$$ = {Nombre : "ASIGNACION" , vector :[$1,$3]};}
           //incrementos 
           | ATRIBUTOS OP_Incremento COMPLETAR_ASIGNACION S_PuntoComa                                                   {$$ = {Nombre : "ASIGNACION" , vector :[{Nombre : "ASIGNACION", vector : [$1 ,{Nombre : $2 , vector : undefined}]},$3]};}
           | OP_Incremento ATRIBUTOS COMPLETAR_ASIGNACION S_PuntoComa                                                   {$$ = {Nombre : "ASIGNACION" , vector :[{Nombre : "ASIGNACION", vector : [{Nombre : $1 , vector : undefined} ,$2]},$3]};}   
           | ATRIBUTOS OP_Decremento COMPLETAR_ASIGNACION S_PuntoComa                                                   {$$ = {Nombre : "ASIGNACION" , vector :[{Nombre : "ASIGNACION", vector : [$1 ,{Nombre : $2 , vector : undefined}]},$3]};}
           | OP_Decremento ATRIBUTOS COMPLETAR_ASIGNACION S_PuntoComa                                                   {$$ = {Nombre : "ASIGNACION" , vector :[{Nombre : "ASIGNACION", vector : [{Nombre : $1 , vector : undefined} ,$2]},$3]};}
           | ATRIBUTOS S_Punto R_Push S_ParentesisAbre LISTA_DE_ASIGNACIONES S_ParentesisCierra  S_PuntoComa            {$$ = {Nombre : "ASIGNACION" , vector : [$1,{Nombre: $3 , vector : undefined},$5]};}
;

COMPLETAR_ASIGNACION : LISTADO_ASIGNACION
                      |                                                                             {$$ = undefined;}
;

LISTADO_ASIGNACION: LISTADO_ASIGNACION  CONTENIDO_ASIGNACION                                        {$$ = { Nombre : "LISTADO_ASIGNACION" , vector : [$1,$2]};}
                  | CONTENIDO_ASIGNACION                                                            {$$ = { Nombre : "LISTADO_ASIGNACION" , vector : [$1]};}
;

CONTENIDO_ASIGNACION: S_Coma Identificador S_Igual EXPRESION_G                                      {$$ = {Nombre : "CONTENIDO_ASIGNACION" , vector : [{Nombre : $2 , vector : undefined},$4]};}
                    | S_Coma Identificador OP_Incremento                                            {$$ = {Nombre : "CONTENIDO_ASIGNACION" , vector : [{Nombre : $2 , vector : undefined},$3]};}
                    | S_Coma OP_Incremento Identificador                                            {$$ = {Nombre : "CONTENIDO_ASIGNACION" , vector : [$2,{Nombre : $3 , vector : undefined}]};}
                    | S_Coma Identificador OP_Decremento                                            {$$ = {Nombre : "CONTENIDO_ASIGNACION" , vector : [{Nombre : $2 , vector : undefined},$3]};}
                    | S_Coma OP_Decremento Identificador                                            {$$ = {Nombre : "CONTENIDO_ASIGNACION" , vector : [$2,{Nombre : $3 , vector : undefined}]};}
;

LISTA_DE_ASIGNACIONES : EXPRESION_G                                                                 {$$ = $1;}
                      | S_CorcheteAbre CONT_ASIG_ARRAY S_CorcheteCierra                             {$$ = $2;}
                      | S_LlaveAbre LISTA_DECLARACION_TYPES S_LlaveCierra                           {$$ = $2;}
;




/*---------------------------------------------LISTA DE ASIGNACION ARRAY DENTRO DE ARRAY---------------------------------------------------------*/
CONT_ASIG_ARRAY: LISTA_ASIGN_ARRAY                                                                                                  
               |                                                                                                                    {$$ = undefined;}
;

LISTA_ASIGN_ARRAY: LISTA_ASIGN_ARRAY S_Coma CONT_ARRAY_ASIGN_VV                                                                     {$$ = {Nombre : "LISTA_ASIGN_ARRAY", vector : [$1,$3]};}
                 | CONT_ARRAY_ASIGN_VV                                                                                              {$$ = {Nombre : "LISTA_ASIGN_ARRAY", vector : [$1]};}
;   

CONT_ARRAY_ASIGN_VV: EXPRESION_G                                                                                                    {$$ = $1;}
                   | S_CorcheteAbre CONT_ASIG_ARRAY S_CorcheteCierra                                                                {$$ = $2;}
                   | S_LlaveAbre LISTA_DECLARACION_TYPES S_LlaveCierra                                                              {$$ = $2;}
;


/*---------------------------------------------VARIABLES---------------------------------------------------------*/

VARIABLES : R_Let LISTADO_VAR S_PuntoComa                                                                                           {$$ = {Nombre : "VARIABLES" , vector : [{Nombre:$1 , vector: undefined},$2]};}
          | R_Const LISTADO_VAR S_PuntoComa                                                                                         {$$ = {Nombre : "VARIABLES" , vector : [{Nombre:$1 , vector: undefined},$2]};}
;

/*---------------------------------------------LISTADO VARIABLES---------------------------------------------------------*/

LISTADO_VAR : LISTADO_VAR S_Coma CONT_VAR                                                                                                           {$$ = { Nombre: "LISTADO_VAR" , vector : [$1,$3]};}
            | CONT_VAR                                                                                                                              {$$ = { Nombre: "LISTADO_VAR" , vector : [$1]};}
;
/*--------------------------------------------- DEFINICION DE VARIABLES---------------------------------------------------------*/

CONT_VAR: Identificador /*declaracion de variable solo id*/                                                                                         {$$ = {Nombre : "VARIABLE" , vector : [{Nombre : $1 , vector : undefined}]};}              
        | Identificador S_DosPuntos TIPOS_DE_DATO  /*declaracion de variable con tipo de dato*/                                                     {$$ = {Nombre : "VARIABLE" , vector : [{Nombre : $1 , vector : undefined},$3]};} 
        | Identificador S_DosPuntos TIPOS_DE_DATO S_Igual EXPRESION_G   /*declaracion de variable con tipo y asignacion de valor*/                  {$$ = {Nombre : "VARIABLE" , vector : [{Nombre : $1 , vector : undefined},$3,$5]};}  
        | Identificador S_Igual EXPRESION_G /*declaracion de variable con asignacion de valor*/                                                     {$$ = {Nombre : "VARIABLE" , vector : [{Nombre : $1 , vector : undefined},$3]};} 


        | Identificador S_Igual S_CorcheteAbre CONT_ASIG_ARRAY S_CorcheteCierra /*array*/                                                           {$$ = {Nombre : "ARRAY" , vector : [{Nombre : $1 , vector : undefined},$4]};}
        | Identificador S_DosPuntos TIPOS_DE_DATO S_CorcheteAbre S_CorcheteCierra /*array*/                                                         {$$ = {Nombre : "ARRAY" , vector : [{Nombre : $1 , vector : undefined},$3]};}
        | Identificador S_DosPuntos TIPOS_DE_DATO S_CorcheteAbre S_CorcheteCierra S_Igual S_CorcheteAbre CONT_ASIG_ARRAY S_CorcheteCierra /*array*/ {$$ = {Nombre : "ARRAY" , vector : [{Nombre : $1 , vector : undefined},$3,$8]};}


        | Identificador S_DosPuntos TIPOS_DE_DATO S_Igual S_LlaveAbre LISTA_DECLARACION_TYPES S_LlaveCierra /*types*/                               {$$ = {Nombre : "TYPE" ,vector : [{Nombre : $1 , vector : undefined},$3,$6]};}
        | Identificador S_Igual S_LlaveAbre LISTA_DECLARACION_TYPES S_LlaveCierra /*types*/                                                         {$$ = {Nombre : "TYPE" ,vector : [{Nombre : $1 , vector : undefined},$4]};}
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
    : Identificador S_ParentesisAbre PARAMETROS_FUNC S_ParentesisCierra S_PuntoComa 
    | ATRIBUTOS S_Punto R_Pop S_ParentesisAbre S_ParentesisCierra S_PuntoComa 
;

PARAMETROS_FUNC
    : PARAMETROS_FUNC S_Coma EXPRESION_G
    | EXPRESION_G
    |                                                                                                   {$$=undefined;}
;

/*---------------------------------------------PARAMETROS---------------------------------------------------------*/
PARAM: LISTA_PARAMETROS
     |
;

LISTA_PARAMETROS : LISTA_PARAMETROS S_Coma PARAMETROS 
                 | PARAMETROS             
;

PARAMETROS : Identificador S_DosPuntos TIPOS_DE_DATO 
           | Identificador S_DosPuntos TIPOS_DE_DATO S_Igual EXPRESION_G
           | Identificador S_Interrogacion S_DosPuntos TIPOS_DE_DATO 
;
/*---------------------------------------------TYPES---------------------------------------------------------*/


TYPES: T_Type Identificador S_Igual S_LlaveAbre LISTA_TYPES FIN_TYPES                                           {$$ = {Nombre: "TYPES" , vector:[{Nombre: $2 ,vector:undefined},$5]};}
;

LISTA_TYPES: LISTA_TYPES SEPARADOR CONTENIDO_TYPES                                                              {$$ = {Nombre: "LISTA_TYPES" , vector : [$1,$3]};}            
           | CONTENIDO_TYPES                                                                                    {$$ = {Nombre: "LISTA_TYPES" , vector : [$1]};}
;

CONTENIDO_TYPES : Identificador S_DosPuntos TIPOS_DE_DATO                                                       {$$ = {Nombre: "CONTENIDO_TYPES", vector : [{Nombre: $1 ,vector:undefined},$3] };}
                | Identificador S_DosPuntos Identificador S_CorcheteAbre S_CorcheteCierra                       {$$ = {Nombre: "CONTENIDO_TYPES", vector : [{Nombre: $1 ,vector:undefined},{Nombre: $3 ,vector:undefined}] };}
;

SEPARADOR : S_Coma
          | S_PuntoComa
;

FIN_TYPES: S_LlaveCierra S_PuntoComa
         | S_LlaveCierra
;

/*---------------------------------------------DECLARACION DE TYPES---------------------------------------------------------*/
LISTA_DECLARACION_TYPES: LISTA_DECLARACION_TYPES SEPARADOR_DECLARACION_TYPES CONTENIDO_DECLARACION_TYPES        {$$ = {Nombre : "", vector : [$1,$2]};}
                        | CONTENIDO_DECLARACION_TYPES                                                           {$$ = {Nombre : "", vector : [$1]};}
;

CONTENIDO_DECLARACION_TYPES : Identificador S_DosPuntos LISTA_DE_ASIGNACIONES                                   {$$ = { Nombre : "CONTENIDO_DECLARACION_TYPES", vector : [{ Nombre : $1 , vector : undefined},$3]};}
;

SEPARADOR_DECLARACION_TYPES : S_Coma
                            | S_PuntoComa
;

/*---------------------------------------------TIPOS DE DATO---------------------------------------------------------*/
TIPOS_DE_DATO : T_Number                                                            {$$ = {Nombre: "TIPOS_DE_DATO" , vector : [{Nombre: $1 , vector : undefined}]};}
              | T_Boolean                                                           {$$ = {Nombre: "TIPOS_DE_DATO" , vector : [{Nombre: $1 , vector : undefined}]};}
              | T_String                                                            {$$ = {Nombre: "TIPOS_DE_DATO" , vector : [{Nombre: $1 , vector : undefined}]};}
              | T_Void                                                              {$$ = {Nombre: "TIPOS_DE_DATO" , vector : [{Nombre: $1 , vector : undefined}]};}
              | Identificador                                                       {$$ = {Nombre: "TIPOS_DE_DATO" , vector : [{Nombre: $1 , vector : undefined}]};}
;
//agrega tipos de dato a funciones anonimas
TIPAR_FUNCION : S_DosPuntos TIPOS_DE_DATO
              |
;
/*---------------------------------------------ACCEDER A ATRIBUTOS---------------------------------------------------------*/

 ATRIBUTOS: ATRIBUTOS S_Punto CONT_ATRIBUTOS                                                      {$$ = {Nombre : "ATRIBUTOS" ,vector:[$1,$3]};}
          | CONT_ATRIBUTOS                                                                        {$$ = {Nombre : "ATRIBUTOS" ,vector:[$1]};}
 ;

 CONT_ATRIBUTOS:  Identificador S_CorcheteAbre EXPRESION_G S_CorcheteCierra                       {$$ = {Nombre: "CONT_ATRIBUTOS" , vector : [{Nombre: $1 , vector : undefined},$3]};}
               |  Identificador                                                                   {$$ = {Nombre: $1 , vector : undefined};}
;

/*---------------------------------------------EXPRESIONES---------------------------------------------------------*/
EXPRESION_G 
    : EXPRESION_G LOG_Concatenar EXPRESION_G                                                     { $$ = {Nombre:"EXPRESION_G",vector : [$1, {Nombre: $2 , vector : undefined},$3]}; }
    | EXPRESION_G LOG_OR EXPRESION_G                                                             { $$ = {Nombre:"EXPRESION_G",vector : [$1, {Nombre: $2 , vector : undefined},$3]}; }
    | EXPRESION_G REL_IgualIgual EXPRESION_G                                                     { $$ = {Nombre:"EXPRESION_G",vector : [$1, {Nombre: $2 , vector : undefined},$3]}; }
    | EXPRESION_G REL_MayorIgualQue EXPRESION_G                                                  { $$ = {Nombre:"EXPRESION_G",vector : [$1, {Nombre: $2 , vector : undefined},$3]}; }
    | EXPRESION_G REL_MayorQue EXPRESION_G                                                       { $$ = {Nombre:"EXPRESION_G",vector : [$1, {Nombre: $2 , vector : undefined},$3]}; }
    | EXPRESION_G REL_MenorIgualQue EXPRESION_G                                                  { $$ = {Nombre:"EXPRESION_G",vector : [$1, {Nombre: $2 , vector : undefined},$3]}; }
    | EXPRESION_G REL_MenorQue EXPRESION_G                                                       { $$ = {Nombre:"EXPRESION_G",vector : [$1, {Nombre: $2 , vector : undefined},$3]}; }
    | EXPRESION_G REL_Distinto EXPRESION_G                                                       { $$ = {Nombre:"EXPRESION_G",vector : [$1, {Nombre: $2 , vector : undefined},$3]}; }    
    | EXPRESION_G OP_Mas EXPRESION_G                                                             { $$ = {Nombre:"EXPRESION_G",vector : [$1, {Nombre: $2 , vector : undefined},$3]}; }                                                    
    | EXPRESION_G OP_Menos EXPRESION_G                                                           { $$ = {Nombre:"EXPRESION_G",vector : [$1, {Nombre: $2 , vector : undefined},$3]}; }                                                          
    | EXPRESION_G OP_Multiplicacion EXPRESION_G                                                  { $$ = {Nombre:"EXPRESION_G",vector : [$1, {Nombre: $2 , vector : undefined},$3]}; }                                                 
    | EXPRESION_G OP_Division EXPRESION_G                                                        { $$ = {Nombre:"EXPRESION_G",vector : [$1, {Nombre: $2 , vector : undefined},$3]}; }                                            
    | EXPRESION_G OP_Exponenciacion EXPRESION_G                                                  { $$ = {Nombre:"EXPRESION_G",vector : [$1, {Nombre: $2 , vector : undefined},$3]}; }                                                 
    | EXPRESION_G OP_Modulo EXPRESION_G                                                          { $$ = {Nombre:"EXPRESION_G",vector : [$1, {Nombre: $2 , vector : undefined},$3]}; }                                                                                                              
    | OP_Menos  CONTENIDO_EXPRESION     %prec UMINUS                                             { $$ = {Nombre:"EXPRESION_G",vector : [{Nombre: $1 , vector : undefined},$2]}; }  
    | LOG_Not   CONTENIDO_EXPRESION     %prec UMINUS                                             { $$ = {Nombre:"EXPRESION_G",vector : [{Nombre: $1 , vector : undefined},$2]}; }  
    | CONTENIDO_EXPRESION                                                                        { $$ = {Nombre:"EXPRESION_G",vector : [$1]}; } 
;

 CONTENIDO_EXPRESION
    : Entero                                                                                    {$$ = {Nombre: $1 , vector : undefined};}
    | Decimal                                                                                   {$$ = {Nombre: $1 , vector : undefined};}
    | R_True                                                                                    {$$ = {Nombre: $1 , vector : undefined};}
    | R_False                                                                                   {$$ = {Nombre: $1 , vector : undefined};}
    | Cadena                                                                                    {$$ = {Nombre: $1 , vector : undefined};}
    | Identificador S_ParentesisAbre S_ParentesisCierra                                         
    | Identificador S_ParentesisAbre OPCIONAL S_ParentesisCierra                                
    | S_ParentesisAbre EXPRESION_G S_ParentesisCierra                                           {$$ = $2;}
    | ATRIBUTOS
    | ATRIBUTOS S_Punto R_Length
    | ATRIBUTOS S_Punto R_Pop S_ParentesisAbre S_ParentesisCierra
; /*ATRIBUTOS CONTIENE ID Y VECTOR */

OPCIONAL 
    : OPCIONAL S_Coma EXPRESION_G                                                             
    |EXPRESION_G    
; 