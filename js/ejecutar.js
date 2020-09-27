var errorSemantico = [];
var ambitos = [];
var nAmbitos = [];
var log = [];

function ejJson() {
  Consola.setValue("");
  var texto = Codigo.getValue();
  var vector = Reporte_Errores.parse(texto);
  if (vector.Arbol.length > 0) {
    agregarAmbito("global");
    ejecutarArchivo(vector.Arbol);
    if (errorSemantico.length != 0) {
      if (vector.Errores.length != 0) {
        errorSemantico = vector.Errores.concat(errorSemantico);
        LlenarVariables(errorSemantico);
      } else {
        LlenarVariables(errorSemantico);
      }
    } else {
      if (vector.Errores.length != 0) {
        LlenarVariables(vector.Errores);
      }
    }
  } else {
    Consola.setValue("!Problema al ejecutar codigo!");
  }
  //IMPRIMIENDO LOS AMBITOS
  //console.log(ambitos);
  eliminarA();
  console.log(log);
  ambitos = [];
}

function ejecutarArchivo(json) {
  for (var element of json) {
    if (element.tipoInstruccion == "CONSOLE") {
      ejecutarImprimir(element.contenido);
    } else if (element.tipoInstruccion == "DECLARACION") {
      verificarDeclaracion(element);
    } else if (element.tipoInstruccion == "GRAFICARTS") {
      graficar();
    } else if (element.tipoInstruccion == "ASIGNACION") {
      ejecutarAsignacion(element);
    } else if (element.tipoInstruccion == "ASIGNACION_INC_D") {
      ejecutarAsignacion(element);
    } else if (element.tipoInstruccion == "ASIGNACION_INC_A") {
      ejecutarAsignacion(element);
    } else if (element.tipoInstruccion == "ASIGNACION_DEC_D") {
      ejecutarAsignacion(element);
    } else if (element.tipoInstruccion == "ASIGNACION_DEC_A") {
      ejecutarAsignacion(element);
    } else if (element.tipoInstruccion == "LISTADO_IF") {
      ejecutarIF(element.contenido);
    } else if (element.tipoInstruccion == "WHILE") {
      ejecutarWhile(element);
    } else if (element.tipoInstruccion == "DOWHILE") {
      ejecutarDoWhile(element);
    }
  }
}
//////////////////////////////////////////////////INSTRUCCION IMPRIMIR
function ejecutarImprimir(elemento) {
  var id;
  if (Array.isArray(elemento)) {
    id = elemento[0];
  } else {
    id = elemento;
  }
  var result = leerExp(id);
  if (result.tipo == "Error Semantico") {
    errorSemantico.push(result);
  } else {
    setter(result.valor);
  }
}
//////////////////////////////////////////////////DECLARACIONES
function verificarDeclaracion(elemento) {
  for (var element of elemento.contenido) {
    if (element.tipo == "VARIABLE") {
      ejecutarDeclaracion(element, elemento.modificador, rNomAmbito());
    } else if (element.tipo == "ARRAY_ST") {
      //console.log(element.tipo);
      declaracionArrayST(element, elemento.modificador, rNomAmbito());
    } else if (element.tipo == "ARRAY_CT") {
      //console.log(element.tipo);
      declaracionArrayCT(element, elemento.modificador, rNomAmbito());
    } else if (element.tipo == "ARRAY_CTV") {
      //console.log(element.tipo);
      declaracionArrayCTV(element, elemento.modificador, rNomAmbito());
    }
  }
}
/////////////////////////////////////////////////INSTRUCCION DECLARACION DE VARIABLE
function ejecutarDeclaracion(ele, mod, ambi) {
  //var mod = elemento.modificador;
  //for (var ele of elemento.contenido) {
  var val;
  //BUSCAR SI NO EXISTE LA VARIABLE EN LOS AMBITOS DISPONIBLES
  if (!buscarVariable(ele.identificador)) {
    //VERIFICO SI TIENE VALOR
    if (ele.valor != undefined) {
      //SI TIENE VALOR
      val = leerExp(ele.valor);
      //VEIRIFICO SI TIENE TIPO
      if (ele.tipoDato != undefined) {
        // SI TIENE TIPO Y ES IGUAL AL QUE SERA ASIGNADO
        if (compararTipo(ele.tipoDato, val.tipo) == true) {
          //SE VERIFICA SI EL VALOR DEVUELTO NO TIENE ERROR
          if (val.tipo != "Error Semantico") {
            insertarAmbito({
              tipo: ele.tipo,
              ambito: rNomAmbito(),
              modificador: mod,
              identificador: ele.identificador,
              tipoDato: val.tipo,
              valor: val.valor,
              fila: ele.fila,
            });
          } else {
            //SI EL VALOR INGRESADO TENIA ERROR
            errorSemantico.push({
              tipo: val.tipo,
              Error: val.desc,
              Fila: val.fila,
              Columna: 0,
            });
          }
        } else {
          //ERROR SI NO SE ASIGNA EL MISMO TIPO
          errorSemantico.push({
            tipo: "Error Semantico",
            Error: "valor asignado incompatible con el declarado",
            Fila: ele.fila,
            Columna: 0,
          });
        }
      } else {
        // SI NO TIENE TIPO SE AGREGA EL MISMO TIPO QUE EL VALOR ASIGNADO
        insertarAmbito({
          tipo: ele.tipo,
          ambito: rNomAmbito(),
          modificador: mod,
          identificador: ele.identificador,
          tipoDato: val.tipo,
          valor: val.valor,
          fila: ele.fila,
        });
      }
    } else {
      //SI NO TIENE VALOR SE ASIGNA LO MISMO QUE CUANDO SE DECLARO
      insertarAmbito({
        tipo: ele.tipo,
        ambito: rNomAmbito(),
        modificador: mod,
        identificador: ele.identificador,
        tipoDato: ele.tipoDato,
        valor: ele.valor,
        fila: ele.fila,
      });
    }
  } else {
    //ERROR SI EXISTE UNA VARIABLE CON EL MISMO ID EN LOS AMBITOS
    errorSemantico.push({
      tipo: "Error Semantico",
      Error: "variable ya declarada -> " + ele.identificador,
      Fila: ele.fila,
      Columna: 0,
    });
  }
  //}
}

/////////////////////////////////////////////////INSTRUCCION DECLARACION DE VECTOR SIN TIPO CON VALOR
function declaracionArrayST(ele, mod, ambi) {
  //console.log(ele);
  var encontreError = false;
  //BUSCANDO VECTOR EN LOS AMBITOS SI NO ESTA SE REALIZA DECLARACION
  if (!buscarVariable(ele.identificador)) {
    //VERIFICAR EXPRESIONES
    var v = [];
    //console.log(ele.valor.length);
    //VERIFICANDO TAMAñO DE VECTOR DE VALORES PARA SABER SI ES NECESARIO ASIGNAR VALORES
    if (ele.valor.length > 0) {
      //console.log("traigo valores");
      //AGREGANDO VALORES
      for (var e of ele.valor) {
        var exp = leerExp(e);
        if (e.tipo != "Error Semantico") {
          v.push(exp.valor);
        } else {
          encontreError = true;
          errorSemantico.push(exp);
          break;
        }
      }
      //SI NO SE ENCONTRO UN ERROR SE HACE LA CREACION DE LA VARIABLE
      if (encontreError == false) {
        insertarAmbito({
          tipo: ele.tipo,
          ambito: rNomAmbito(),
          modificador: mod,
          identificador: ele.identificador,
          tipoDato: undefined,
          valor: v,
          fila: ele.fila,
        });
      } else {
        errorSemantico.push({
          tipo: "Error Semantico",
          Error:
            "Problema al declarar vector con valores no validos -> " +
            ele.identificador,
          Fila: ele.fila,
          Columna: 0,
        });
      }
    } else {
      //SI NO ES NECESARIO AGREGAR VALORES
      //console.log("no traigo valores");
      insertarAmbito({
        tipo: ele.tipo,
        ambito: rNomAmbito(),
        modificador: mod,
        identificador: ele.identificador,
        tipoDato: undefined,
        valor: v,
        fila: ele.fila,
      });
    }
  } else {
    //SI HAY UNA VARIABLE DECLARADA CON EL MISMO NOMBRE SE REPORTA ERROR
    errorSemantico.push({
      tipo: "Error Semantico",
      Error: "variable ya declarada -> " + ele.identificador,
      Fila: ele.fila,
      Columna: 0,
    });
  }
}
/////////////////////////////////////////////////INSTRUCCION DECLARACION DE VECTOR CON TIPO
function declaracionArrayCT(ele, mod, ambi) {
  //BUSCANDO VARIABLE PARA SABER SI YA ESTA DECLARADA
  if (!buscarVariable(ele.identificador)) {
    console.log("me puedo declarar");
    insertarAmbito({
      tipo: ele.tipo,
      ambito: rNomAmbito(),
      modificador: mod,
      identificador: ele.identificador,
      tipoDato: ele.tipoDato,
      valor: undefined,
      fila: ele.fila,
    });
  } else {
    //ERROR QUE NO ESTA DECLARADA LA VARIABLE
    //console.log("estoy declarado");
    errorSemantico.push({
      tipo: "Error Semantico",
      Error: "variable ya declarada -> " + ele.identificador,
      Fila: ele.fila,
      Columna: 0,
    });
  }
}
/////////////////////////////////////////////////INSTRUCCION DECLARACION DE VECTOR CON TIPO Y VALOR
function declaracionArrayCTV(ele, mod, ambi) {
  var encontreError = false;
  //BUSCANDO VECTOR EN LOS AMBITOS SI NO ESTA SE REALIZA DECLARACION
  if (!buscarVariable(ele.identificador)) {
    //VERIFICAR EXPRESIONES
    var v = [];
    //console.log(ele.valor.length);
    //VERIFICANDO TAMAñO DE VECTOR DE VALORES PARA SABER SI ES NECESARIO ASIGNAR VALORES
    if (ele.valor.length > 0) {
      //console.log("traigo valores");
      //AGREGANDO VALORES
      for (var e of ele.valor) {
        var exp = leerExp(e);
        if (e.tipo != "Error Semantico") {
          if (ele.tipoDato == exp.tipo) {
            v.push(exp.valor);
          } else {
            encontreError = true;
            errorSemantico.push({
              tipo: "Error Semantico",
              Error:
                "Problema al insertar valores que no coinciden con tipo de vector " +
                exp.valor,
              Fila: ele.fila,
              Columna: 0,
            });
            break;
          }
        } else {
          encontreError = true;
          errorSemantico.push(exp);
          break;
        }
      }
      //SI NO SE ENCONTRO UN ERROR SE HACE LA CREACION DE LA VARIABLE
      if (encontreError == false) {
        insertarAmbito({
          tipo: ele.tipo,
          ambito: rNomAmbito(),
          modificador: mod,
          identificador: ele.identificador,
          tipoDato: undefined,
          valor: v,
          fila: ele.fila,
        });
      } else {
        errorSemantico.push({
          tipo: "Error Semantico",
          Error:
            "Problema al declarar vector con valores no validos -> " +
            ele.identificador,
          Fila: ele.fila,
          Columna: 0,
        });
      }
    } else {
      //SI NO ES NECESARIO AGREGAR VALORES
      //console.log("no traigo valores");
      insertarAmbito({
        tipo: ele.tipo,
        ambito: rNomAmbito(),
        modificador: mod,
        identificador: ele.identificador,
        tipoDato: undefined,
        valor: v,
        fila: ele.fila,
      });
    }
  } else {
    //SI HAY UNA VARIABLE DECLARADA CON EL MISMO NOMBRE SE REPORTA ERROR
    errorSemantico.push({
      tipo: "Error Semantico",
      Error: "variable ya declarada -> " + ele.identificador,
      Fila: ele.fila,
      Columna: 0,
    });
  }
}
/////////////////////////////////////////////////INSTRUCCION ASIGNACION DE VARIABLE
function ejecutarAsignacion(elemento) {
  for (var ele of elemento.contenido) {
    if (ele.tipoInstruccion == "ASIGNACION") {
      asigVar(ele);
    } else if (ele.tipoInstruccion == "ASIGNACION_INC_D") {
      incVarD(ele);
    } else if (ele.tipoInstruccion == "ASIGNACION_INC_A") {
      incVarA(ele);
    } else if (ele.tipoInstruccion == "ASIGNACION_DEC_D") {
      decVarD(ele);
    } else if (ele.tipoInstruccion == "ASIGNACION_DEC_A") {
      decVarA(ele);
    }
  }
}
/////////////////////////////////////////////////INSTRUCCION ASIGNACION DE VARIABLE
function asigVar(ele) {
  //SI EXISTE SE PUEDE ASIGNAR VALOR
  var idAs = lAcceso(ele.identificador);
  //BUSCANDO LA TABLA DE SIMBOLOS EN LOS AMBITOS
  if (buscarVariable(idAs.valor)) {
    //OBTENIENDO EL ELEMENTO DE LOS AMBITOS
    var variable = buscarVModificar(ele, idAs.valor);
    //VERIFICAR SI LA VARIABLE NO ES CONSTANTE
    if (variable.modificador != "const") {
      //SE OBTIENE EL VALOR QUE SE VA A ASIGNAR
      var lee = leerExp(ele.valor);
      //SI LA EXPRESION NO RETORNO ERROR
      if (lee.tipo != "Error Semantico") {
        //SE COMPARAN LOS TIPOS ANTES DE ASIGNAR EL VALOR
        if (variable.tipoDato == lee.tipo) {
          variable.valor = lee.valor;
        } else if (variable.tipoDato == undefined) {
          var tipV = typeof lee.valor;
          variable.valor = lee.valor;
          variable.tipoDato = asignarTipo(tipV);
          console.log(variable);
        } else {
          //SI LOS TIPOS NO SON IGUALES SE REPORTA ERROR
          errorSemantico.push({
            tipo: "Error Semantico",
            Error:
              "El valor a asignar no es compatible al definido por la variable " +
              variable.identificador,
            Fila: variable.fila,
            Columna: variable.fila,
          });
        }
      } else {
        //SI LA EXPRESION RETORNO UN ERROR SEMANTICO SE REPORTA Y NO SE REALIZ AASGINACION
        errorSemantico.push({
          tipo: "Error Semantico",
          Error: lee.Error,
          Fila: lee.fila,
          Columna: lee.fila,
        });
      }
    } else {
      //SI LA VARIABLE ES CONSTANTE SE REPORTA ERROR
      errorSemantico.push({
        tipo: "Error Semantico",
        Error:
          "No se puede reasignar valor a variable constante  " + idAs.valor,
        Fila: idAs.fila,
        Columna: 0,
      });
    }
  } else {
    //SI NO EXISTE ES ERROR
    errorSemantico.push({
      tipo: "Error Semantico",
      Error: "Necesita declarar variable  " + idAs.valor,
      Fila: idAs.fila,
      Columna: 0,
    });
  }
}
/////////////////////////////////////////////////INSTRUCCION ASIGNACION INCREMENTO DESPUES
function incVarD(ele) {
  var idAs = lAcceso(ele.identificador);
  //SABER SI EXISTE VARIABLE
  if (buscarVariable(idAs.valor)) {
    //OBTENIENDO VARIABLE DE AMBITOS
    var variable = buscarVModificar(ele, idAs.valor);
    if (variable.modificador != "const") {
      //SE VERIFICA SI ES NUMERO PARA QUE SE PUEDA AUMENTAR EL VALOR
      if (variable.tipoDato == "NUMERO") {
        variable.valor++;
      } else {
        //NO SE PUEDE AUMENTAR EL VALOR DE VARIABLE
        errorSemantico.push({
          tipo: "Error Semantico",
          Error: "Tipo de dato incompatible con el incremento  " + idAs.valor,
          Fila: idAs.fila,
          Columna: 0,
        });
      }
    } else {
      //SI ES CONSTANTE SE REPORTA ERROR
      errorSemantico.push({
        tipo: "Error Semantico",
        Error:
          "No se puede reasignar valor a variable constante  " + idAs.valor,
        Fila: idAs.fila,
        Columna: 0,
      });
    }
  } else {
    //SI NO EXISTE VARIABLE
    errorSemantico.push({
      tipo: "Error Semantico",
      Error: "Necesita declarar variable  " + idAs.valor,
      Fila: idAs.fila,
      Columna: 0,
    });
  }
}
/////////////////////////////////////////////////INSTRUCCION ASIGNACION INCREMENTO ANTES
function incVarA(ele) {
  var idAs = lAcceso(ele.identificador);
  //SABER SI EXISTE VARIABLE
  if (buscarVariable(idAs.valor)) {
    //OBTENIENDO VARIABLE DE AMBITOS
    var variable = buscarVModificar(ele, idAs.valor);
    if (variable.modificador != "const") {
      //SE VERIFICA SI ES NUMERO PARA QUE SE PUEDA AUMENTAR EL VALOR
      if (variable.tipoDato == "NUMERO") {
        ++variable.valor;
      } else {
        //NO SE PUEDE AUMENTAR EL VALOR DE VARIABLE
        errorSemantico.push({
          tipo: "Error Semantico",
          Error: "Tipo de dato incompatible con el incremento  " + idAs.valor,
          Fila: idAs.fila,
          Columna: 0,
        });
      }
    } else {
      //SI ES CONSTANTE SE REPORTA ERROR
      errorSemantico.push({
        tipo: "Error Semantico",
        Error:
          "No se puede reasignar valor a variable constante  " + idAs.valor,
        Fila: idAs.fila,
        Columna: 0,
      });
    }
  } else {
    //SI NO EXISTE VARIABLE
    errorSemantico.push({
      tipo: "Error Semantico",
      Error: "Necesita declarar variable  " + idAs.valor,
      Fila: idAs.fila,
      Columna: 0,
    });
  }
}
/////////////////////////////////////////////////INSTRUCCION ASIGNACION DECREMENTO DESPUES
function decVarD(ele) {
  var idAs = lAcceso(ele.identificador);
  //SABER SI EXISTE VARIABLE
  if (buscarVariable(idAs.valor)) {
    //OBTENIENDO VARIABLE DE AMBITOS
    var variable = buscarVModificar(ele, idAs.valor);
    if (variable.modificador != "const") {
      //SE VERIFICA SI ES NUMERO PARA QUE SE PUEDA AUMENTAR EL VALOR
      if (variable.tipoDato == "NUMERO") {
        variable.valor--;
      } else {
        //NO SE PUEDE AUMENTAR EL VALOR DE VARIABLE
        errorSemantico.push({
          tipo: "Error Semantico",
          Error: "Tipo de dato incompatible con el incremento  " + idAs.valor,
          Fila: idAs.fila,
          Columna: 0,
        });
      }
    } else {
      //SI ES CONSTANTE SE REPORTA ERROR
      errorSemantico.push({
        tipo: "Error Semantico",
        Error:
          "No se puede reasignar valor a variable constante  " + idAs.valor,
        Fila: idAs.fila,
        Columna: 0,
      });
    }
  } else {
    //SI NO EXISTE VARIABLE
    errorSemantico.push({
      tipo: "Error Semantico",
      Error: "Necesita declarar variable  " + idAs.valor,
      Fila: idAs.fila,
      Columna: 0,
    });
  }
}
/////////////////////////////////////////////////INSTRUCCION ASIGNACION DECREMENTO ANTES
function decVarA(ele) {
  var idAs = lAcceso(ele.identificador);
  //SABER SI EXISTE VARIABLE
  if (buscarVariable(idAs.valor)) {
    //OBTENIENDO VARIABLE DE AMBITOS
    var variable = buscarVModificar(ele, idAs.valor);
    if (variable.modificador != "const") {
      //SE VERIFICA SI ES NUMERO PARA QUE SE PUEDA AUMENTAR EL VALOR
      if (variable.tipoDato == "NUMERO") {
        --variable.valor;
      } else {
        //NO SE PUEDE AUMENTAR EL VALOR DE VARIABLE
        errorSemantico.push({
          tipo: "Error Semantico",
          Error: "Tipo de dato incompatible con el incremento  " + idAs.valor,
          Fila: idAs.fila,
          Columna: 0,
        });
      }
    } else {
      //SI ES CONSTANTE SE REPORTA ERROR
      errorSemantico.push({
        tipo: "Error Semantico",
        Error:
          "No se puede reasignar valor a variable constante  " + idAs.valor,
        Fila: idAs.fila,
        Columna: 0,
      });
    }
  } else {
    //SI NO EXISTE VARIABLE
    errorSemantico.push({
      tipo: "Error Semantico",
      Error: "Necesita declarar variable  " + idAs.valor,
      Fila: idAs.fila,
      Columna: 0,
    });
  }
}
////////////////////////////////////////////////INSTRUCCION GRAFICAR TS
function graficar() {
  generarTablas(ambitos);
}
////////////////////////////////////////////////INSTRUCCION IF
function ejecutarIF(ele) {
  //console.log(ele);
  var ejecuteIf = false;
  for (var element of ele) {
    //console.log(element);
    if (element.tipoInstruccion == "IF") {
      //console.log(element.condicion);
      var exp = leerExp(element.condicion);
      //console.log(exp);
      //VERIFICO QUE LA EXPRESION SEA VALIDA
      if (exp.tipo != "Error Semantico") {
        if (exp.tipo != "BOOLEAN" || exp.valor != false || exp.opR != 0) {
          if (exp.valor == true) {
            //console.log("instrucciones del if");
            //aqui se agrega el ambito
            agregarAmbito("IF");
            ejecutarArchivo(element.instrucciones);
            //aqui se elimina el ambito
            eliminarA();
            //ejecuteIf = true;
            break;
          }
        }
      } else {
        //SI LA EXPRESION NO ES VALIDA
        errorSemantico.push(exp);
        //ejecuteIf = true;
      }
    }
    //&& ejecuteIf == false
    if (element.tipoInstruccion == "ELSE") {
      //console.log("hijole");
      agregarAmbito("ELSE");
      ejecutarArchivo(element.instrucciones);
      eliminarA();
    }
    //var exp = leerExp();
  }
}
////////////////////////////////////////////////INSTRUCCION WHILE
function ejecutarWhile(ele) {
  //OBTENIENDO EL VALOR DE LA CONDICION
  var exp = leerExp(ele.condicion);
  //console.log(exp);
  //VERIFICANDO QUE SEA UNA EXPRESION VALIDA
  if (exp.tipo != "Error Semantico") {
    console.log(exp);
    console.log(ele.instrucciones);
    while (exp.valor) {
      console.log(exp);
      agregarAmbito("WHILE");
      ejecutarArchivo(ele.instrucciones);
      eliminarA();
      exp = leerExp(ele.condicion);
    }
  } else {
    //REPORTANDO ERROR SI LA EXPRESION NO ES VALIDA
    errorSemantico.push(exp);
  }
}
////////////////////////////////////////////////INSTRUCCION DO WHILE
function ejecutarDoWhile(ele) {
  //console.log(ele);
  var exp = leerExp(ele.condicion);
  //console.log(exp);
  //SE COMPRUEBA QUE SEA UNA EXPRESION VALIDA
  if (exp.tipo != "Error Semantico") {
    console.log(ele.instrucciones);
    do {
      agregarAmbito("DOWHILE");
      ejecutarArchivo(ele.instrucciones);
      eliminarA();
      exp = leerExp(ele.condicion);
    } while (exp.valor);
  } else {
    //SI ES UNA EXPRESION NO VALIDA SE HACE UN ERROR
    errorSemantico.push(exp);
  }
}
////////////////////////////////////////////////INSTRUCCION SWITCH
function ejecutarSwitch(ele) {}

//////////////////////////////////////////////// REALIZAR OPERACION
function leerExp(exp) {
  if (
    exp.tipo == "OPERACION_SUMA" ||
    exp.tipo == "OPERACION_RESTA" ||
    exp.tipo == "OPERACION_MULTIPLICACION" ||
    exp.tipo == "OPERACION_DIVISION" ||
    exp.tipo == "OPERACION_EXPONENCIACION" ||
    exp.tipo == "OPERACION_MODULO"
  ) {
    return ejecutarAritmetica(exp);
  } else if (
    exp.tipo == "OPERACION_MAYORQUE" ||
    exp.tipo == "OPERACION_MAYORIGUALQUE" ||
    exp.tipo == "OPERACION_MENORIGUALQUE" ||
    exp.tipo == "OPERACION_MENORQUE" ||
    exp.tipo == "OPERACION_DISTINTO" ||
    exp.tipo == "OPERACION_IGUALIGUAL"
  ) {
    return ejecutarRelacional(exp);
  } else if (
    exp.tipo == "OPERACION_AND" ||
    exp.tipo == "OPERACION_OR" ||
    exp.tipo == "OPERACION_NOT"
  ) {
    return ejecutarLogicas(exp);
  } else if (exp.tipo == "OPERACION_NEGATIVO") {
    return ejecutarNegativo(exp);
  } else if (exp.tipo == "OPERACION_INCREMENTO_D") {
    return ejecutarIncrementoD(exp);
  } else if (exp.tipo == "OPERACION_INCREMENTO_A") {
    return ejecutarIncrementoA(exp);
  } else if (exp.tipo == "OPERACION_DECREMENTO_D") {
    return ejecutarDecrementoD(exp);
  } else if (exp.tipo == "OPERACION_DECREMENTO_A") {
    return ejecutarDecrementoA(exp);
  } else if (exp.tipo == "NUMERO") {
    return { tipo: exp.tipo, opR: 0, valor: exp.valor, fila: exp.fila };
  } else if (exp.tipo == "CADENA") {
    return { tipo: exp.tipo, opR: 0, valor: exp.valor, fila: exp.fila };
  } else if (exp.tipo == "BOOLEAN") {
    return { tipo: exp.tipo, opR: 0, valor: exp.valor, fila: exp.fila };
  } else if (exp.tipo == "UNDEFINED") {
    return { tipo: exp.tipo, opR: 0, valor: exp.valor, fila: exp.fila };
  } else if (exp.tipo == "IDENTIFICADOR") {
    return recuperarId(exp);
  } else if (Array.isArray(exp)) {
    var id = lAcceso(exp);
    if (id.tipo != "IDENTIFICADOR") {
      return leerExp(id);
    } else {
      var vla = buscarAmbId(exp, id.valor);
      var tipoVar = typeof vla.valor;
      if (vla.tipo == "Error Semantico") {
        return vla;
      } else {
        return {
          tipo: asignarTipo(tipoVar),
          opR: 0,
          valor: vla.valor,
          fila: vla.fila,
        };
      }
    }
  }
}

function recuperarId(exp) {
  var ele = buscarAmbId(exp, exp.valor);
  if (ele.tipo == "Error Semantico") {
    return {
      tipo: "Error Semantico",
      Error: "Necesita declarar variable  " + exp.valor,
      Fila: exp.fila,
      Columna: 0,
    };
  } else {
    return { tipo: ele.tipo, opR: 0, valor: ele.valor, fila: ele.fila };
  }
}
/////////////////////////////////////////////////OPERACIONES ARITMETICAS
function ejecutarAritmetica(exp) {
  var opI = leerExp(exp.opIzq);
  var opD = leerExp(exp.opDer);
  if (opI.tipo != "Error Semantico" && opD.tipo != "Error Semantico") {
    if (exp.tipo == "OPERACION_SUMA") {
      return validarTipoS(opI, opD);
    } else if (exp.tipo == "OPERACION_RESTA") {
      return validarTiposOP(opI, opD, "RES");
    } else if (exp.tipo == "OPERACION_MULTIPLICACION") {
      return validarTiposOP(opI, opD, "MULT");
    } else if (exp.tipo == "OPERACION_DIVISION") {
      return validarTiposOP(opI, opD, "DIV");
    } else if (exp.tipo == "OPERACION_EXPONENCIACION") {
      return validarTiposOP(opI, opD, "POT");
    } else if (exp.tipo == "OPERACION_MODULO") {
      return validarTiposOP(opI, opD, "MOD");
    }
  } else {
    if (opI.tipo == "Error Semantico") {
      return opI;
    } else if (opD.tipo == "Error Semantico") {
      return opD;
    }
  }
}
/////////////////////////////////////////////////VALIDANDO LOS TIPOS DE LAS OPERACIONES ARITMETICAS
function validarTipoS(opIzq, opDer) {
  if (opDer.tipo == "NUMERO") {
    if (opIzq.tipo == "NUMERO" || opIzq.tipo == "CADENA") {
      var op = opIzq.valor + opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, opR: 1, valor: op };
    }
  } else if (opDer.tipo == "CADENA") {
    if (
      opIzq.tipo == "NUMERO" ||
      opIzq.tipo == "BOOLEAN" ||
      opIzq.tipo == "CADENA" ||
      opIzq.tipo == "UNDEFINED"
    ) {
      var op = opIzq.valor + opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, opR: 1, valor: op };
    }
  } else if (opDer.tipo == "BOOLEAN") {
    if (opIzq.tipo == "CADENA") {
      var op = opIzq.valor + opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, opR: 1, valor: op };
    }
  } else if (opDer.tipo == "UNDEFINED") {
    if (opIzq.tipo == "CADENA") {
      var op = opIzq.valor + opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, opR: 1, valor: op };
    }
  }
  return {
    tipo: "Error Semantico",
    Error: "valor incompatible con operacion aritmetica",
    Fila: opDer.fila,
    Columna: 0,
  };
}

function validarTiposOP(opIzq, opDer, tipOp) {
  if (opIzq.tipo == "NUMERO" && opDer.tipo == "NUMERO") {
    if (tipOp == "RES") {
      var op = opIzq.valor - opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, opR: 1, valor: op };
    } else if (tipOp == "MULT") {
      var op = opIzq.valor * opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, opR: 1, valor: op };
    } else if (tipOp == "DIV") {
      var op = opIzq.valor / opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, opR: 1, valor: op };
    } else if (tipOp == "POT") {
      var op = opIzq.valor ** opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, opR: 1, valor: op };
    } else if (tipOp == "MOD") {
      var op = opIzq.valor % opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, opR: 1, valor: op };
    }
  }
  return {
    tipo: "Error Semantico",
    Error: "valor incompatible con operacion aritmetica",
    Fila: opDer.fila,
    Columna: 0,
  };
}
/////////////////////////////////////////////////OPERACIONES RELACIONALES
function ejecutarRelacional(exp) {
  var opI = leerExp(exp.opIzq);
  var opD = leerExp(exp.opDer);
  if (opI.tipo != "Error Semantico" && opD.tipo != "Error Semantico") {
    if (exp.tipo == "OPERACION_MAYORIGUALQUE") {
      return validarTipoMM(opI, opD, "MAIQ");
    } else if (exp.tipo == "OPERACION_MAYORQUE") {
      return validarTipoMM(opI, opD, "MAQ");
    } else if (exp.tipo == "OPERACION_MENORIGUALQUE") {
      return validarTipoMM(opI, opD, "MEIQ");
    } else if (exp.tipo == "OPERACION_MENORQUE") {
      return validarTipoMM(opI, opD, "MEQ");
    } else if (exp.tipo == "OPERACION_DISTINTO") {
      return validarTipoDist(opI, opD);
    } else if (exp.tipo == "OPERACION_IGUALIGUAL") {
      return validarTipoIgIg(opI, opD, exp.opIzq.tipo, exp.opDer.tipo);
    }
  } else {
    if (opI.tipo == "Error Semantico") {
      return opI;
    } else if (opD.tipo == "Error Semantico") {
      return opD;
    }
  }
}

function validarTipoMM(opIzq, opDer, tipoOp) {
  if (opIzq.tipo == opDer.tipo) {
    if (tipoOp == "MAIQ") {
      var op = opIzq.valor >= opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, opR: 1, valor: op };
    } else if (tipoOp == "MAQ") {
      var op = opIzq.valor > opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, opR: 1, valor: op };
    } else if (tipoOp == "MEIQ") {
      var op = opIzq.valor <= opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, opR: 1, valor: op };
    } else if (tipoOp == "MEQ") {
      var op = opIzq.valor < opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, opR: 1, valor: op };
    }
  }
  return {
    tipo: "Error Semantico",
    Error: "valor incompatible con operacion relacional",
    Fila: opDer.fila,
    Columna: 0,
  };
}

function validarTipoIgIg(opIzq, opDer, topI, topD) {
  console.log(topI);
  console.log(topD);
  if (
    opIzq.tipo != "IDENTIFICADOR" &&
    opIzq.tipo != "UNDEFINED" &&
    opDer.tipo != "IDENTIFICADOR" &&
    opDer.tipo != "UNDEFINED"
  ) {
    if (opIzq.opR == 1 || opDer.opR == 1) {
      var op = opIzq.valor == opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, valor: op };
    } else if (opIzq.valor == opDer.valor) {
      var op = opIzq.valor == opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, valor: op };
    }
  } else if (
    opIzq.tipo == "IDENTIFICADOR" ||
    opIzq.tipo == "UNDEFINED" ||
    opDer.tipo == "IDENTIFICADOR" ||
    opDer.tipo == "UNDEFINED"
  ) {
    var op = opIzq.valor == opDer.valor;
    var tip = asignarTipo(typeof op);
    return { tipo: tip, valor: op };
  }
  return {
    tipo: "Error Semantico",
    Error: "valor incompatible con operacion relacional",
    Fila: opDer.fila,
    Columna: 0,
  };
}

function validarTipoDist(opIzq, opDer) {
  if (
    opIzq.tipo != "IDENTIFICADOR" &&
    opIzq.tipo != "UNDEFINED" &&
    opDer.tipo != "IDENTIFICADOR" &&
    opDer.tipo != "UNDEFINED"
  ) {
    if (opIzq.opR == 1 || opDer.opR == 1) {
      var op = opIzq.valor != opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, valor: op };
    } else if (opIzq.valor == opDer.valor) {
      var op = opIzq.valor != opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, valor: op };
    }
  } else if (
    opIzq.tipo == "IDENTIFICADOR" ||
    opIzq.tipo == "UNDEFINED" ||
    opDer.tipo == "IDENTIFICADOR" ||
    opDer.tipo == "UNDEFINED"
  ) {
    var op = opIzq.valor != opDer.valor;
    var tip = asignarTipo(typeof op);
    return { tipo: tip, valor: op };
  }
  return {
    tipo: "Error Semantico",
    Error: "valor incompatible con operacion relacional",
    Fila: opDer.fila,
    Columna: 0,
  };
}
/////////////////////////////////////////////////OPERACIONES LOGICAS
function ejecutarLogicas(exp) {
  var opI = leerExp(exp.opIzq);
  var opD = leerExp(exp.opDer);
  if (opI.tipo != "Error Semantico" && opD.tipo != "Error Semantico") {
    if (exp.tipo == "OPERACION_AND") {
      return validarTiposLog(opI, opD, "AND");
    } else if (exp.tipo == "OPERACION_OR") {
      return validarTiposLog(opI, opD, "OR");
    } else if (exp.tipo == "OPERACION_NOT") {
      return validarTiposLog(opI, opD, "NOT");
    }
  } else {
    if (opI.tipo == "Error Semantico") {
      return opI;
    } else if (opD.tipo == "Error Semantico") {
      return opD;
    }
  }
}

function validarTiposLog(opIzq, opDer, tipOp) {
  if (tipOp == "AND") {
    var op = opIzq.valor && opDer.valor;
    var tip = asignarTipo(typeof op);
    return { tipo: tip, valor: op };
  } else if (tipOp == "OR") {
    var op = opIzq.valor || opDer.valor;
    var tip = asignarTipo(typeof op);
    return { tipo: tip, valor: op };
  } else if (tipOp == "NOT") {
    var op = !opIzq.valor;
    var tip = asignarTipo(typeof op);
    return { tipo: tip, valor: op };
  }
}
/////////////////////////////////////////////////OPERACIONES NEGATIVO
function ejecutarNegativo(exp) {
  var opI = leerExp(exp.opIzq);
  var opD = leerExp(exp.opDer);

  if (opI.tipo != "UNDEFINED") {
    var op = opI.valor * -1;
    var tip = asignarTipo(typeof op);
    return { tipo: tip, valor: op };
  }
  return {
    tipo: "Error Semantico",
    Error: "valor incompatible con operacion negacion",
    Fila: opI.fila,
    Columna: 0,
  };
}
/////////////////////////////////////////////////OPERACIONES INCREMENTO
function ejecutarIncrementoD(exp) {
  if (Array.isArray(exp.opIzq)) {
    var id = lAcceso(exp.opIzq).valor;
    var el = buscarAmbId(exp, id);
    if (el.tipo != "Error Semantico") {
      if (el.modificador != "const") {
        if (el.tipoDato == "NUMERO") {
          var f = el.valor++;
          var tip = typeof el.valor;
          return { tipo: tip, valor: f, opR: 1, fila: el.fila };
        } else {
          return {
            tipo: "Error Semantico",
            Error: "Tipo de dato incompatible con operacion de incremento",
            Fila: el.fila,
            Columna: 0,
          };
        }
      } else {
        return {
          tipo: "Error Semantico",
          Error: "No se puede modificar el valor de una constante",
          Fila: el.fila,
          Columna: 0,
        };
      }
    } else {
      return el;
    }
  } else {
    return {
      tipo: "Error Semantico",
      Error: "El incremento unicamente funciona con variables",
      Fila: exp.opIzq.fila,
      Columna: 0,
    };
  }
}

function ejecutarIncrementoA(exp) {
  if (Array.isArray(exp.opIzq)) {
    var id = lAcceso(exp.opIzq).valor;
    var el = buscarAmbId(exp, id);
    if (el.tipo != "Error Semantico") {
      if (el.modificador != "const") {
        if (el.tipoDato == "NUMERO") {
          var f = ++el.valor;
          var tip = typeof el.valor;
          return { tipo: tip, valor: f, opR: 1, fila: el.fila };
        } else {
          return {
            tipo: "Error Semantico",
            Error: "Tipo de dato incompatible con operacion de incremento",
            Fila: el.fila,
            Columna: 0,
          };
        }
      } else {
        return {
          tipo: "Error Semantico",
          Error: "No se puede modificar el valor de una constante",
          Fila: el.fila,
          Columna: 0,
        };
      }
    } else {
      return el;
    }
  } else {
    return {
      tipo: "Error Semantico",
      Error: "El incremento unicamente funciona con variables",
      Fila: exp.opIzq.fila,
      Columna: 0,
    };
  }
}

function ejecutarDecrementoD(exp) {
  if (Array.isArray(exp.opIzq)) {
    var id = lAcceso(exp.opIzq).valor;
    var el = buscarAmbId(exp, id);
    if (el.tipo != "Error Semantico") {
      if (el.modificador != "const") {
        if (el.tipoDato == "NUMERO") {
          var f = el.valor--;
          var tip = typeof el.valor;
          return { tipo: tip, valor: f, opR: 1, fila: el.fila };
        } else {
          return {
            tipo: "Error Semantico",
            Error: "Tipo de dato incompatible con operacion de incremento",
            Fila: el.fila,
            Columna: 0,
          };
        }
      } else {
        return {
          tipo: "Error Semantico",
          Error: "No se puede modificar el valor de una constante",
          Fila: el.fila,
          Columna: 0,
        };
      }
    } else {
      return el;
    }
  } else {
    return {
      tipo: "Error Semantico",
      Error: "El incremento unicamente funciona con variables",
      Fila: exp.opIzq.fila,
      Columna: 0,
    };
  }
}

function ejecutarDecrementoA(exp) {
  if (Array.isArray(exp.opIzq)) {
    var id = lAcceso(exp.opIzq).valor;
    var el = buscarAmbId(exp, id);
    if (el.tipo != "Error Semantico") {
      if (el.modificador != "const") {
        if (el.tipoDato == "NUMERO") {
          var f = --el.valor;
          var tip = typeof el.valor;
          return { tipo: tip, valor: f, opR: 1, fila: el.fila };
        } else {
          return {
            tipo: "Error Semantico",
            Error: "Tipo de dato incompatible con operacion de incremento",
            Fila: el.fila,
            Columna: 0,
          };
        }
      } else {
        return {
          tipo: "Error Semantico",
          Error: "No se puede modificar el valor de una constante",
          Fila: el.fila,
          Columna: 0,
        };
      }
    } else {
      return el;
    }
  } else {
    return {
      tipo: "Error Semantico",
      Error: "El incremento unicamente funciona con variables",
      Fila: exp.opIzq.fila,
      Columna: 0,
    };
  }
}
/////////////////////////////////////////////////COLOCA RESULTADO EN CONSOLA
function setter(val) {
  var txt = Consola.getValue();
  Consola.setValue(txt + val + "\n");
}
/////////////////////////////////////////////////DEVUELVE TIPOS ACORDE A LA  GRAMATICA
function asignarTipo(tipo) {
  if (tipo == "number") {
    return "NUMERO";
  } else if (tipo == "string") {
    return "CADENA";
  } else if (tipo == "boolean") {
    return "BOOLEAN";
  } else if (tipo == "undefined") {
    return "UNDEFINED";
  }
}
////////////////////////////////////////////////FUNCION QUE INSERTA EN EL ULTIMO AMBITO DISPONIBLE
function insertarAmbito(val) {
  ambitos[ambitos.length - 1].push(val);
}
////////////////////////////////////////////////FUNCION QUE COMPRUEBA TIPOS DE DATO CON VALOR ASIGNADO
function compararTipo(tAsig, tVal) {
  if (tAsig == tVal) {
    return true;
  } else {
    return false;
  }
}
///////////////////////////////////////////////FUNCION QUE BUSCAN ID EN AMBITOS Y RETORNA TRUE O FALSE
function buscarVariable(idV) {
  for (var i = ambitos.length - 1; i >= 0; i--) {
    for (var element of ambitos[i]) {
      if (element.identificador == idV) {
        return true;
      }
    }
  }
  return false;
}
//////////////////////////////////////////////FUNCION QUE BUSCA UN ID Y RETORNA ESE ELEMENTO PARA SER MODIFICADO
function buscarVModificar(ele, idV) {
  for (var i = ambitos.length - 1; i >= 0; i--) {
    for (var element of ambitos[i]) {
      if (element.identificador == idV) {
        return element;
      }
    }
  }
  return {
    tipo: "Error Semantico",
    Error: "Necesita declarar variable para asignar valor " + ele.identificador,
    Fila: ele.fila,
    Columna: 0,
  };
}

function buscarAmbId(ele, idV) {
  for (var i = ambitos.length - 1; i >= 0; i--) {
    for (var element of ambitos[i]) {
      if (element.identificador == idV) {
        return element;
      }
    }
  }
  return {
    tipo: "Error Semantico",
    Error: "Necesita declarar variable  " + idV,
    Fila: ele.fila,
    Columna: 0,
  };
}
//////////////////////////////////////////////FUNCION QUE RETORNA ID PARA OPERACIONES
function separar(opIzq, opDer) {
  if (opIzq.tipo == "IDENTIFICADOR") {
    var opIzq = buscarAmbId(opI);
  } else if (opDer == "IDENTIFICADOR") {
  }
}
//////////////////////////////////////////////LISTA DE ACCESO
function lAcceso(op) {
  if (op.length == 1) {
    //es una variable
    return op[0];
  }
}
///////////////////////////////////////////////AGREGAR AMBITO
function agregarAmbito(nombre) {
  ambitos.push([]);
  nAmbitos.push(nombre);
}
//////////////////////////////////////////////ELMINAR AMBITO
function eliminarA() {
  //agregando ambito elminado al log de cambios
  log.push(ambitos.pop());
  //eliminando nombre de vector de nombres
  nAmbitos.pop();
}
//////////////////////////////////////////////RETORNAR NOMBRE DEL AMBITO
function rNomAmbito() {
  return nAmbitos[nAmbitos.length - 1];
}
