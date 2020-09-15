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
"**"                                                {return 'OP_Exponenciacion';}
"+"                                                 {return 'OP_Mas';}
"-"                                                 {return 'OP_Menos';}
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
%{
function expresion(valor1, operador, valor2) {
    var json = [];
    json = json.concat(returnVector(valor1));
    json = json.concat(returnVector(operador));
    json = json.concat(returnVector(valor2));
    return json;
}

function unaria(valor1,valor2){
    var json = [];
    json = json.concat(returnVector(valor1));
    json = json.concat(returnVector(valor2));
    return json;
}

function returnVector(val){
    if(Array.isArray(val)==true){
        return val;
    }else{
        return [val];
    }
}
%}

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
INICIO : CONT EOF {console.log($1);}
;
/*---------------------------------------------LISTA DE CONTENIDO GLOBAL---------------------------------------------------------*/
CONT: LISTA_CONTENIDO {$$ =$1;}
    |
;

LISTA_CONTENIDO : CONTENIDO LISTA_CONTENIDO_PRIM                {$$ = $2;}               
;

LISTA_CONTENIDO_PRIM : CONTENIDO LISTA_CONTENIDO_PRIM          {$$ = $2;} 
                    |                                           {
                                                                var pila = eval('$$');
                                                                var valSintetizar = pila[pila.length - 1 ];
                                                                $$ = valSintetizar;
                                                                }
;

//CONTENIDO GLOBAL
CONTENIDO : FUNCIONES                   { 
                                        var pila = eval('$$');
                                        //console.log(pila);
                                        var anterior = pila[pila.length - 2];  
                                        if(Array.isArray(anterior)){
                                            var temp = anterior.concat($1);
                                        }else{
                                            var temp  = [$1];
                                        }
                                        $$ = temp;
                                        }
          | ESTRUCTURAS_DE_CONTROL      { 
                                        var pila = eval('$$');
                                        //console.log(pila);
                                        var anterior = pila[pila.length - 2];  
                                        if(Array.isArray(anterior)){
                                            var temp = anterior.concat($1);
                                        }else{
                                            var temp  = [$1];
                                        }
                                        $$ = temp;
                                        }
          |  error  {$$ ='';console.log({ Tipo_Error  : ' Error_Sintactico ', Error  : yytext , Fila  : this._$.first_line , Columna  :  this._$.first_column });}
;
/*---------------------------------------------DEFINICION DE FUNCIONES---------------------------------------------------------*/
FUNCIONES : R_Funcion Identificador S_ParentesisAbre PARAM S_ParentesisCierra S_LlaveAbre CONT S_LlaveCierra {var json  = { tipo: "funcion" , contenido : [{tipo : "identificador", contenido : $2},{tipo : "parametros", contenido : $4},{tipo : "instrucciones", contenido : $7}]};$$ = json;}
          | R_Funcion Identificador S_ParentesisAbre PARAM S_ParentesisCierra S_DosPuntos TIPOS_DE_DATO S_LlaveAbre CONT S_LlaveCierra {var json = {tipo : "funcion" ,contenido : [{tipo : "identificador", contenido : $2},{tipo : "parametros", contenido : $4},{tipo : "tipoDato", contenido : $7},{tipo : "instrucciones", contenido : $9}] }; $$ = json;}
          | R_Let Identificador S_Igual R_Funcion S_ParentesisAbre PARAM S_ParentesisCierra TIPAR_FUNCION S_LlaveAbre CONT S_LlaveCierra S_PuntoComa //{var json = {tipo : "funcion" ,contenido : [{tipo : "concatenar", contenido :$1} , {tipo : "identificador", contenido :$2},{tipo : "concatenar", contenido :$3},{tipo : "concatenar", contenido :$4},{tipo : "concatenar", contenido :$5},{tipo : "parametros", contenido :$6},{tipo : "concatenar", contenido :$7},{tipo : "concatenar", contenido :$8},{tipo : "concatenar", contenido :$9},{tipo : "instrucciones", contenido :$10},{tipo : "concatenar", contenido :$11},{tipo : "concatenar", contenido :$12}] }; $$ = json;}
          | R_Const Identificador S_Igual R_Funcion S_ParentesisAbre PARAM S_ParentesisCierra TIPAR_FUNCION S_LlaveAbre CONT S_LlaveCierra S_PuntoComa //{var json = {tipo : "funcion" ,contenido : [{tipo : "concatenar", contenido :$1} , {tipo : "identificador", contenido :$2},{tipo : "concatenar", contenido :$3},{tipo : "concatenar", contenido :$4},{tipo : "concatenar", contenido :$5},{tipo : "parametros", contenido :$6},{tipo : "concatenar", contenido :$7},{tipo : "concatenar", contenido :$8},{tipo : "concatenar", contenido :$9},{tipo : "instrucciones", contenido :$10},{tipo : "concatenar", contenido :$11},{tipo : "concatenar", contenido :$12}] }; $$ = json;}
;
/*---------------------------------------------LISTADO DE ESTRUCTURAS DE CONTROL---------------------------------------------------------*/
EDD:LISTADO_ESTRUCTURAS
   |
;

LISTADO_ESTRUCTURAS : LISTADO_ESTRUCTURAS CONT_ESTRUCTURAS_CONTROL
                    | CONT_ESTRUCTURAS_CONTROL
;

CONT_ESTRUCTURAS_CONTROL : ESTRUCTURAS_DE_CONTROL
                         |error  {$$ ='';console.log({ Tipo_Error  : ' Error_Sintactico ', Error  : yytext , Fila  : this._$.first_line , Columna  :  this._$.first_column });}
;

ESTRUCTURAS_DE_CONTROL: VARIABLES
                      | ASIGNACION
                      | LISTADO_IF ELSE
                      | SWITCH
                      | IMPRIMIR
                      | WHILE
                      | DO_WHILE
                      | FOR
                      | FOR_OF
                      | FOR_IN
                      | SENTENCIAS_TRANSFERENCIA
                      | LLAMADA_FUNC
                      | TYPES

;
/*--------------------------------------------- SENTENCIAS DE TRANSFERENCIA ---------------------------------------------------------*/

SENTENCIAS_TRANSFERENCIA : R_Break S_PuntoComa
                         | R_Continue S_PuntoComa
                         | R_Return S_PuntoComa
                         | R_Return EXPRESION_G S_PuntoComa
;

/*--------------------------------------------- LISTADO IF---------------------------------------------------------*/
LISTADO_IF : LISTADO_IF R_Else IF                                                       
           | IF
;

IF : R_If S_ParentesisAbre EXPRESION_G S_ParentesisCierra S_LlaveAbre EDD S_LlaveCierra         {$$ = $1+$2+$3+$4+$5+$6+$7;}
;

ELSE : R_Else S_LlaveAbre EDD S_LlaveCierra
     |
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
IMPRIMIR: R_Console S_Punto R_Log S_ParentesisAbre FUNC S_ParentesisCierra S_PuntoComa {$$ = $1+$2+$3+$4+$5+$6+$7;}
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

ASIGNACION : ATRIBUTOS S_Igual LISTA_DE_ASIGNACIONES S_PuntoComa                        {var json = $1; json.push({tipo : "concatenar" , contenido : $2}); json = json.concat($3);json.push({tipo : "concatenar" , contenido : $4});$$ = {tipo : "asignacion" , contenido : json};}
           //incrementos 
           | ATRIBUTOS OP_Incremento COMPLETAR_ASIGNACION S_PuntoComa                   {var json = $1; json.push({tipo : "concatenar" , contenido : $2}); json = json.concat($3);json.push({tipo : "concatenar" , contenido : $4});$$ = {tipo : "asignacion" , contenido : json};}
           | OP_Incremento ATRIBUTOS COMPLETAR_ASIGNACION S_PuntoComa                   {var json = [{tipo : "concatenar", contenido : $1}]; json = json.concat($2);json = json.concat($3);json.push({tipo : "concatenar" , contenido : $4});$$ = {tipo : "asignacion" , contenido : json};}
           | ATRIBUTOS OP_Decremento COMPLETAR_ASIGNACION S_PuntoComa                   {var json = $1; json.push({tipo : "concatenar" , contenido : $2}); json = json.concat($3);json.push({tipo : "concatenar" , contenido : $4});$$ = {tipo : "asignacion" , contenido : json};}
           | OP_Decremento ATRIBUTOS COMPLETAR_ASIGNACION S_PuntoComa                   {var json = [{tipo : "concatenar", contenido : $1}]; json = json.concat($2); json = json.concat($3);json.push({tipo : "concatenar" , contenido : $4});$$ = {tipo : "asignacion" , contenido : json};}
           | ATRIBUTOS S_Punto R_Push S_ParentesisAbre LISTA_DE_ASIGNACIONES S_ParentesisCierra  S_PuntoComa {var json = $1; json.push({tipo : "concatenar" , contenido : $2});json.push({tipo : "concatenar" , contenido : $3});json.push({tipo : "concatenar" , contenido : $4}); json = json.concat($5); json.push({ tipo : "concatenar" , contenido : $6});json.push({ tipo : "concatenar" , contenido : $7}); $$ = {tipo : "asignacion" , contenido : json};}
;

COMPLETAR_ASIGNACION : LISTADO_ASIGNACION
                      |                                                     {$$ = [];}
;

LISTADO_ASIGNACION: LISTADO_ASIGNACION  CONTENIDO_ASIGNACION                {var json = $1; json = json.concat($2);$$ = json;}
                  | CONTENIDO_ASIGNACION                                    {$$ = $1;}
;

CONTENIDO_ASIGNACION: S_Coma Identificador S_Igual EXPRESION_G              { var json = [{tipo : "concatenar" , contenido : $1},{tipo : "identificador" , contenido : $2},{tipo : "concatenar" , contenido : $3}]; json = json.concat($4);$$ = json;}
                    | S_Coma Identificador OP_Incremento                    { var json = [{tipo : "concatenar" , contenido : $1},{tipo : "identificador" , contenido : $2},{tipo : "concatenar" , contenido : $3}];$$ = json;}
                    | S_Coma OP_Incremento Identificador                    { var json = [{tipo : "concatenar" , contenido : $1},{tipo : "concatenar"    , contenido : $2},{tipo : "identificador" , contenido : $3}]; $$ = json;}
                    | S_Coma Identificador OP_Decremento                    { var json = [{tipo : "concatenar" , contenido : $1},{tipo : "identificador" , contenido : $2},{tipo : "concatenar" , contenido : $3}];$$ = json;}
                    | S_Coma OP_Decremento Identificador                    { var json = [{tipo : "concatenar" , contenido : $1},{tipo : "concatenar"    , contenido : $2},{tipo : "identificador" , contenido : $3}]; $$ = json;}
;

LISTA_DE_ASIGNACIONES : EXPRESION_G                                             {$$ = $1;}
                      | S_CorcheteAbre CONT_ASIG_ARRAY S_CorcheteCierra         {var json = []; json.push({tipo : "concatenar" , contenido : $1});json = json.concat($2);json.push({tipo : "concatenar" , contenido : $3}); $$ = json;}
                      | S_LlaveAbre LISTA_DECLARACION_TYPES S_LlaveCierra       {var json = []; json.push({tipo : "concatenar" , contenido : $1});json = json.concat($2);json.push({tipo : "concatenar" , contenido : $3}); $$ = json;}
;




/*---------------------------------------------LISTA DE ASIGNACION ARRAY DENTRO DE ARRAY---------------------------------------------------------*/
CONT_ASIG_ARRAY: LISTA_ASIGN_ARRAY
               |                                                            {$$ = [];}
;

LISTA_ASIGN_ARRAY: LISTA_ASIGN_ARRAY S_Coma CONT_ARRAY_ASIGN_VV             {var json = [] ; $1.push({tipo : "concatenar" , contenido : $2}); json = $1.concat($3); $$ = json;}
                 | CONT_ARRAY_ASIGN_VV                                      {$$ = $1;}
;   

CONT_ARRAY_ASIGN_VV: EXPRESION_G                                            {$$ = $1;}
                   | S_CorcheteAbre CONT_ASIG_ARRAY S_CorcheteCierra        {var json = []; json.push({tipo : "concatenar" , contenido : $1});json = json.concat($2);json.push({tipo : "concatenar" , contenido : $3}); $$ = json;}
                   | S_LlaveAbre LISTA_DECLARACION_TYPES S_LlaveCierra      {var json = []; json.push({tipo : "concatenar" , contenido : $1});json = json.concat($2);json.push({tipo : "concatenar" , contenido : $3}); $$ = json;}
;


/*---------------------------------------------VARIABLES---------------------------------------------------------*/

VARIABLES : R_Let LISTADO_VAR S_PuntoComa                       {var json = []; json = json.concat($2); json.push({tipo : "concatenar" , contenido : $3}); $$ = {tipo : "variable_let" , contenido : json};}
          | R_Const LISTADO_VAR S_PuntoComa                     {var json = []; json = json.concat($2); json.push({tipo : "concatenar" , contenido : $3}); $$ = {tipo : "variable_const" , contenido : json};}
;

/*---------------------------------------------LISTADO VARIABLES---------------------------------------------------------*/

LISTADO_VAR : LISTADO_VAR S_Coma CONT_VAR                       {$1.push({tipo : "concatenar" , contenido : $2});var json = $1.concat($3);$$ = json;}
            | CONT_VAR                                          {$$ = $1;}
;
/*--------------------------------------------- DEFINICION DE VARIABLES---------------------------------------------------------*/

CONT_VAR: Identificador /*declaracion de variable solo id*/                                                                         {$$ = [{tipo : "identificador" ,contenido : $1}];}
        | Identificador S_DosPuntos TIPOS_DE_DATO  /*declaracion de variable con tipo de dato*/                                     {var json = [{tipo : "identificador" ,contenido : $1},{tipo : "concatenar" ,contenido : $2},{tipo : "tipoDato" ,contenido : $3}];$$ = json;}
        | Identificador S_DosPuntos TIPOS_DE_DATO S_Igual EXPRESION_G   /*declaracion de variable con tipo y asignacion de valor*/  {var json = [{tipo : "identificador" ,contenido : $1},{tipo : "concatenar" ,contenido : $2},{tipo : "tipoDato" ,contenido : $3},{tipo : "tipoDato" ,contenido : $4}];json = json.concat($5);$$ = json;}
        | Identificador S_Igual EXPRESION_G /*declaracion de variable con asignacion de valor*/                                     {var json = [{tipo : "identificador" ,contenido : $1},{tipo : "concatenar" ,contenido : $2}];json = json.concat($3);$$ = json;}


        | Identificador S_Igual S_CorcheteAbre CONT_ASIG_ARRAY S_CorcheteCierra /*array*/                                                             {var json = [{tipo : "identificador" ,contenido : $1},{tipo : "concatenar" ,contenido : $2},{tipo : "concatenar" ,contenido : $3}]; json = json.concat($4);json.push({tipo : "concatenar" ,contenido : $5});$$ = json;}
        | Identificador S_DosPuntos TIPOS_DE_DATO S_CorcheteAbre S_CorcheteCierra /*array*/                                                           {var json = [{tipo : "identificador" ,contenido : $1},{tipo : "concatenar" ,contenido : $2},{tipo : "tipoDato" ,contenido : $3},{tipo : "concatenar" ,contenido : $4},{tipo : "concatenar" ,contenido : $5}];$$ = json;}
        | Identificador S_DosPuntos TIPOS_DE_DATO S_CorcheteAbre S_CorcheteCierra S_Igual S_CorcheteAbre CONT_ASIG_ARRAY S_CorcheteCierra /*array*/   {var json = [{tipo : "identificador" ,contenido : $1},{tipo : "concatenar" ,contenido : $2},{tipo : "tipoDato" ,contenido : $3},{tipo : "concatenar" ,contenido : $4},{tipo : "concatenar" ,contenido : $5},{tipo : "concatenar" ,contenido : $6},{tipo : "concatenar" ,contenido : $7}];json = json.concat($8);json.push({tipo : "concatenar" ,contenido : $9});$$ = json;}


        | Identificador S_DosPuntos TIPOS_DE_DATO S_Igual S_LlaveAbre LISTA_DECLARACION_TYPES S_LlaveCierra /*types*/                                 {var json = [{tipo : "identificador" ,contenido : $1},{tipo : "concatenar" ,contenido : $2},{tipo : "tipoDato" ,contenido : $3},{tipo : "concatenar" ,contenido : $4},{tipo : "concatenar" ,contenido : $5}];json = json.concat($6);json.push({tipo : "concatenar" ,contenido : $7});$$ = json;}
        | Identificador S_Igual S_LlaveAbre LISTA_DECLARACION_TYPES S_LlaveCierra /*types*/                                                           {var json = [{tipo : "identificador" ,contenido : $1},{tipo : "concatenar" ,contenido : $2},{tipo : "concatenar" ,contenido : $3}]; json = json.concat($4);json.push({tipo : "concatenar" ,contenido : $5});$$=json;}
;

/*---------------------------------------------LLAMADAS A FUNCION---------------------------------------------------------*/

LLAMADA_FUNC
    : Identificador S_ParentesisAbre PARAMETROS_FUNC S_ParentesisCierra S_PuntoComa         {var temp = []; temp.push({tipo : "identificador" , contenido : $1});temp.push({tipo : "concatenar" , contenido : $2}); temp = temp.concat($3);temp.push({tipo : "concatenar" , contenido : $4});temp.push({tipo : "concatenar" , contenido : $5});$$ = { tipo : "llamadaF" , contenido : temp};}
    | ATRIBUTOS S_Punto R_Pop S_ParentesisAbre S_ParentesisCierra S_PuntoComa               {var json = $1; json.push({tipo : "concatenar" , contenido : $2});json.push({tipo : "concatenar" , contenido : $3});json.push({tipo : "concatenar" , contenido : $4});json.push({tipo : "concatenar" , contenido : $5});json.push({tipo : "concatenar" , contenido : $6});$$ = {tipo : "llamadaF" , contenido : json};}
;

PARAMETROS_FUNC
    : PARAMETROS_FUNC S_Coma EXPRESION_G                                    {var json = $1; json.push({tipo : "concatenar" , contenido : $2}); json = json.concat($3);$$ = json;}
    | EXPRESION_G                                                           {$$ = $1;}
    |                                                                       {$$ = [];}
;

/*---------------------------------------------PARAMETROS---------------------------------------------------------*/
PARAM: LISTA_PARAMETROS
     |                                                  {$$=[];}
;

LISTA_PARAMETROS : LISTA_PARAMETROS S_Coma PARAMETROS  {$1.push({tipo:"concatenar",contenido : $2});$1.push($3); $$ = $1;}
                 | PARAMETROS {$$=[$1];}              
;

PARAMETROS : Identificador S_DosPuntos TIPOS_DE_DATO  {var json = {tipo : "parametro" , contenido : [{tipo : "identificador" , contenido : $1},{tipo : "concatenar" , contenido : $2},{tipo : "tipoDato" , contenido : $3}]} ; $$ = json;}
           | Identificador S_DosPuntos TIPOS_DE_DATO S_Igual EXPRESION_G {var json = {tipo : "parametro" , contenido : [{tipo : "identificador" , contenido : $1},{tipo : "concatenar" , contenido : $2},{tipo : "tipoDato" , contenido : $3},{tipo : "concatenar" , contenido : $4},{tipo : "expresion" , contenido : $5}]} ; $$ = json;}
           | Identificador S_Interrogacion S_DosPuntos TIPOS_DE_DATO //{var json = {tipo : "" , contenido :} ; $$ = json;}
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
LISTA_DECLARACION_TYPES: LISTA_DECLARACION_TYPES SEPARADOR_DECLARACION_TYPES CONTENIDO_DECLARACION_TYPES        {var json = $1;json.push($2); json = json.concat($3);$$ =json;}
                        | CONTENIDO_DECLARACION_TYPES                                                           {$$ = $1;}
;

CONTENIDO_DECLARACION_TYPES : Identificador S_DosPuntos LISTA_DE_ASIGNACIONES                                   {var json = [{tipo : "identificador" , contenido : $1},{tipo : "concatenar" , contenido : $2}].concat($3);$$ = json;}
;

SEPARADOR_DECLARACION_TYPES : S_Coma                                                                            {$$ = {tipo : "concatenar" , contenido : $1};}
                            | S_PuntoComa                                                                       {$$ = {tipo : "concatenar" , contenido : $1};}
;

/*---------------------------------------------TIPOS DE DATO---------------------------------------------------------*/
// ESTO NO SE MODIFICA PARA RETORNAR VALORES PARA FORMAR JSON
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

 ATRIBUTOS: ATRIBUTOS S_Punto CONT_ATRIBUTOS                                                    {$1.push({tipo : "concatenar" , contenido : $2});$1.push($3);$$=$1;}
          | CONT_ATRIBUTOS                                                                      {$$ = $1;}
 ;

 CONT_ATRIBUTOS:  Identificador S_CorcheteAbre EXPRESION_G S_CorcheteCierra                     { var json = [{tipo : "identificador" , contenido : $1},{tipo : "concatenar" , contenido : $2}]; var temp = json.concat($3); temp.push({tipo : "concatenar" , contenido : $4}); $$ = temp;}
               |  Identificador                                                                 {var json  = [{tipo : "identificador" , contenido : $1}]; $$ = json;}
;

/*---------------------------------------------EXPRESIONES---------------------------------------------------------*/
EXPRESION_G 
    : EXPRESION_G LOG_Concatenar EXPRESION_G                                                     { $$ = expresion($1,{ tipo : "concatenar", contenido : $2},$3);}
    | EXPRESION_G LOG_OR EXPRESION_G                                                             { $$ = expresion($1,{ tipo : "concatenar", contenido : $2},$3);}
    | EXPRESION_G REL_IgualIgual EXPRESION_G                                                     { $$ = expresion($1,{ tipo : "concatenar", contenido : $2},$3);}
    | EXPRESION_G REL_MayorIgualQue EXPRESION_G                                                  { $$ = expresion($1,{ tipo : "concatenar", contenido : $2},$3);}
    | EXPRESION_G REL_MayorQue EXPRESION_G                                                       { $$ = expresion($1,{ tipo : "concatenar", contenido : $2},$3);}
    | EXPRESION_G REL_MenorIgualQue EXPRESION_G                                                  { $$ = expresion($1,{ tipo : "concatenar", contenido : $2},$3);}
    | EXPRESION_G REL_MenorQue EXPRESION_G                                                       { $$ = expresion($1,{ tipo : "concatenar", contenido : $2},$3);}
    | EXPRESION_G REL_Distinto EXPRESION_G                                                       { $$ = expresion($1,{ tipo : "concatenar", contenido : $2},$3);}     
    | EXPRESION_G OP_Mas EXPRESION_G                                                             { $$ = expresion($1,{ tipo : "concatenar", contenido : $2},$3);}
    | EXPRESION_G OP_Menos EXPRESION_G                                                           { $$ = expresion($1,{ tipo : "concatenar", contenido : $2},$3);}
    | EXPRESION_G OP_Multiplicacion EXPRESION_G                                                  { $$ = expresion($1,{ tipo : "concatenar", contenido : $2},$3);}
    | EXPRESION_G OP_Division EXPRESION_G                                                        { $$ = expresion($1,{ tipo : "concatenar", contenido : $2},$3);}
    | EXPRESION_G OP_Exponenciacion EXPRESION_G                                                  { $$ = expresion($1,{ tipo : "concatenar", contenido : $2},$3);}
    | EXPRESION_G OP_Modulo EXPRESION_G                                                          { $$ = expresion($1,{ tipo : "concatenar", contenido : $2},$3);}
    | CONTENIDO_EXPRESION OP_Decremento %prec PRUEBA                                             { $$ = unaria($1,{ tipo : "concatenar", contenido : $2}); }
    | CONTENIDO_EXPRESION OP_Incremento %prec PRUEBA                                             { $$ = unaria($1,{ tipo : "concatenar", contenido : $2}); }
    | OP_Decremento CONTENIDO_EXPRESION                                                          { $$ = unaria({ tipo : "concatenar", contenido : $1},$2); }
    | OP_Incremento CONTENIDO_EXPRESION                                                          { $$ = unaria({ tipo : "concatenar", contenido : $1},$2); }
    | OP_Menos  CONTENIDO_EXPRESION     %prec UMINUS                                             { $$ = unaria({ tipo : "concatenar", contenido : $1},$2); }
    | LOG_Not   CONTENIDO_EXPRESION     %prec UMINUS                                             { $$ = unaria({ tipo : "concatenar", contenido : $1},$2); }
    | CONTENIDO_EXPRESION
;

 CONTENIDO_EXPRESION
    : Entero                                                                                    {var json  = {tipo : "valor" , contenido : $1}; $$ = json;}
    | Decimal                                                                                   {var json  = {tipo : "valor" , contenido : $1}; $$ = json;}
    | R_True                                                                                    {var json  = {tipo : "valor" , contenido : $1}; $$ = json;}
    | R_False                                                                                   {var json  = {tipo : "valor" , contenido : $1}; $$ = json;}
    | Cadena                                                                                    {var json  = {tipo : "valor" , contenido : $1}; $$ = json;}
    | Identificador S_ParentesisAbre S_ParentesisCierra                                         { var json = [{tipo : "identificador" , contenido : $1},{tipo : "concatenar" , contenido : $2},{tipo : "concatenar" , contenido : $3}]; $$ = json;}
    | Identificador S_ParentesisAbre OPCIONAL S_ParentesisCierra                                { var json = [{tipo : "identificador" , contenido : $1},{tipo : "concatenar" , contenido : $2}]; var temp = json.concat($3); temp.push({tipo : "concatenar" , contenido : $4}); $$ = temp;}
    | S_ParentesisAbre EXPRESION_G S_ParentesisCierra                                           { $$ = expresion({ tipo : "concatenar", contenido : $1},$2,{ tipo : "concatenar", contenido : $3});}                                                               
    | ATRIBUTOS                                                                                 {$$ = $1;}
    | ATRIBUTOS S_Punto R_Length                                                                {$1.push({tipo : "concatenar" , contenido : $2 });$1.push({tipo : "concatenar" , contenido : $3 });$$=$1;}
    | ATRIBUTOS S_Punto R_Pop S_ParentesisAbre S_ParentesisCierra                               {$1.push({tipo : "concatenar" , contenido : $2 });$1.push({tipo : "concatenar" , contenido : $3 });$1.push({tipo : "concatenar" , contenido : $4 });$1.push({tipo : "concatenar" , contenido : $5 });$$=$1;}
; /*ATRIBUTOS CONTIENE ID Y VECTOR */

OPCIONAL 
    : OPCIONAL S_Coma EXPRESION_G                                                               {$1.push({tipo : "concatenar" , contenido : $2}); $1.push($3);$$ = $1;}                                                              
    | EXPRESION_G                                                                               {$$ = [$1];}
; 