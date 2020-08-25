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
[\"][^\\\"]*([\\][\\\"ntr][^\\\"]*)*[\"]           {  return 'Cadena'; }
[\'][^\\\"]*([\\][\\\"ntr][^\\\"]*)*[\']           {  return 'Cadena'; }
[\`][^\\\"]*([\\][\\\"ntr][^\\\"]*)*[\`]           {  return 'Cadena'; }


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

/*  NUMEROS */
[0-9]+("."[0-9]+)?\b                               {return 'Decimal';}
[0-9]+\b                                           {return 'Entero';}

/*  IDENTIFICADORES */
([a-zA-Z_])[a-zA-Z0-9_]*                           {return 'Identificador';}
<<EOF>>                                            {  return 'EOF'; }
.     
                                             {console.error("error lexico: " + yytext)}
/lex
%start INICIO

%%
INICIO : Cadena EOF{console.log($$);}
;

LISTA_CADENAS : 

;