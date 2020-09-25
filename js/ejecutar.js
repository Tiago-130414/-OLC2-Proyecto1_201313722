var errorSemantico = [];
var ambitos = [];
var log = [];

function ejJson() {
  Consola.setValue("");
  var texto = Codigo.getValue();
  var vector = Reporte_Errores.parse(texto);
  if (vector.Arbol.length > 0) {
    ambitos.push([]);
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
  console.log(ambitos);
  ambitos = [];
}

function ejecutarArchivo(json) {
  for (var element of json) {
    if (element.tipoInstruccion == "CONSOLE") {
      ejecutarImprimir(element.contenido);
    } else if (element.tipoInstruccion == "DECLARACION") {
      ejecutarDeclaracion(element);
    }
  }
}
//////////////////////////////////////////////////INSTRUCCION IMPRIMIR
function ejecutarImprimir(elemento) {
  var result = leerExp(elemento);
  if (result.tipo == "Error Semantico") {
    errorSemantico.push({
      Tipo_Error: result.tipo,
      Error: result.desc,
      Fila: result.fila,
      Columna: result.fila,
    });
  } else {
    setter(result.valor);
  }
}
/////////////////////////////////////////////////INSTRUCCION DECLARACION DE VARIABLE
function ejecutarDeclaracion(elemento) {
  var mod = elemento.modificador;
  for (var ele of elemento.contenido) {
    var val;
    //console.log(ele.identificador + " " + buscarVariable(ele.identificador));
    if (ele.valor != undefined) {
      val = leerExp(ele.valor);
      //verifica si el valor obtenido no es un error
      if (val.tipo != "Error Semantico") {
        // si la variable no tiene tipo de dato
        if (ele.tipoDato == undefined) {
          //este if compara si la variable ya fue declarada
          if (!buscarVariable(ele.identificador)) {
            insertarAmbito({
              tipo: ele.tipo,
              modificador: mod,
              identificador: ele.identificador,
              tipoDato: val.tipo,
              valor: val.valor,
              fila: ele.fila,
            });
          } else {
            errorSemantico.push({
              Tipo_Error: "Error Semantico",
              Error: "variable ya declarada" + ele.identificador,
              Fila: ele.fila,
              Columna: 0,
            });
          }
        }
        //si la variable tiene tipo de dato y un valor asignado
        else if (compararTipo(ele.tipoDato, val.tipo)) {
          //este if compara si la variable ya fue declarada
          if (!buscarVariable(ele.identificador)) {
            insertarAmbito({
              tipo: ele.tipo,
              modificador: mod,
              identificador: ele.identificador,
              tipoDato: ele.tipo,
              valor: val.valor,
              fila: ele.fila,
            });
          } else {
            errorSemantico.push({
              Tipo_Error: "Error Semantico",
              Error: "variable ya declarada" + ele.identificador,
              Fila: ele.fila,
              Columna: 0,
            });
          }
        }
        //si los tipos no coinciden
        else {
          errorSemantico.push({
            Tipo_Error: "Error Semantico",
            Error: "valor asignado incompatible con el declarado",
            Fila: ele.fila,
            Columna: 0,
          });
        }
      }
      //se reporta el error en cualquier excepcion devuelta por la evaluacion de operacion
      else {
        errorSemantico.push({
          Tipo_Error: val.tipo,
          Error: val.desc,
          Fila: val.fila,
          Columna: 0,
        });
      }
    } else {
      //este if compara si la variable ya fue declarada
      if (!buscarVariable(ele.identificador)) {
        insertarAmbito({
          tipo: ele.tipo,
          modificador: mod,
          identificador: ele.identificador,
          tipoDato: ele.tipoDato,
          valor: ele.valor,
          fila: ele.fila,
        });
      }
      //se reporta el error de variable que ya existe
      else {
        errorSemantico.push({
          Tipo_Error: "Error Semantico",
          Error: "variable ya declarada" + ele.identificador,
          Fila: ele.fila,
          Columna: 0,
        });
      }
    }
  }
}
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
  } else if (exp.tipo == "NUMERO") {
    return { tipo: exp.tipo, opR: 0, valor: exp.valor, fila: exp.fila };
  } else if (exp.tipo == "CADENA") {
    return { tipo: exp.tipo, opR: 0, valor: exp.valor, fila: exp.fila };
  } else if (exp.tipo == "BOOLEAN") {
    return { tipo: exp.tipo, opR: 0, valor: exp.valor, fila: exp.fila };
  } else if (exp.tipo == "UNDEFINED") {
    return { tipo: exp.tipo, opR: 0, valor: exp.valor, fila: exp.fila };
  } else if (exp.tipo == "IDENTIFICADOR") {
    return { tipo: exp.tipo, opR: 0, valor: exp.valor, fila: exp.fila };
  }
}
/////////////////////////////////////////////////OPERACIONES ARITMETICAS
function ejecutarAritmetica(exp) {
  var opI = leerExp(exp.opIzq);
  var opD = leerExp(exp.opDer);
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
    Tipo_Error: "Error Semantico",
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
    Tipo_Error: "Error Semantico",
    Error: "valor incompatible con operacion aritmetica",
    Fila: opDer.fila,
    Columna: 0,
  };
}
/////////////////////////////////////////////////OPERACIONES RELACIONALES
function ejecutarRelacional(exp) {
  var opI = leerExp(exp.opIzq);
  var opD = leerExp(exp.opDer);
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
    return validarTipoIgIg(opI, opD);
  }
}

function validarTipoMM(opIzq, opDer, tipoOp) {
  if (opIzq.tipo == opDer.tipo) {
    if (tipoOp == "MAIQ") {
      var op = opIzq.valor >= opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, valor: op };
    } else if (tipoOp == "MAQ") {
      var op = opIzq.valor > opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, valor: op };
    } else if (tipoOp == "MEIQ") {
      var op = opIzq.valor <= opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, valor: op };
    } else if (tipoOp == "MEQ") {
      var op = opIzq.valor < opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, valor: op };
    }
  }
  return {
    Tipo_Error: "Error Semantico",
    Error: "valor incompatible con operacion relacional",
    Fila: opDer.fila,
    Columna: 0,
  };
}

function validarTipoIgIg(opIzq, opDer) {
  if (
    opIzq.tipo != "IDENTIFICADOR" &&
    opIzq.tipo != "UNDEFINED" &&
    opDer.tipo != "IDENTIFICADOR" &&
    opDer.tipo != "UNDEFINED"
  ) {
    if (opIzq.opR == 1) {
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
    Tipo_Error: "Error Semantico",
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
    if (opIzq.valor == opDer.valor) {
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
    Tipo_Error: "Error Semantico",
    Error: "valor incompatible con operacion relacional",
    Fila: opDer.fila,
    Columna: 0,
  };
}
/////////////////////////////////////////////////OPERACIONES LOGICAS
function ejecutarLogicas(exp) {
  var opI = leerExp(exp.opIzq);
  var opD = leerExp(exp.opDer);
  if (exp.tipo == "OPERACION_AND") {
    return validarTiposLog(opI, opD, "AND");
  } else if (exp.tipo == "OPERACION_OR") {
    return validarTiposLog(opI, opD, "OR");
  } else if (exp.tipo == "OPERACION_NOT") {
    return validarTiposLog(opI, opD, "NOT");
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
    Tipo_Error: "Error Semantico",
    Error: "valor incompatible con operacion negacion",
    Fila: opI.fila,
    Columna: 0,
  };
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

function buscarVariable(idV) {
  console.log(ambitos.length - 1);
  for (var i = ambitos.length - 1; i >= 0; i--) {
    for (var element of ambitos[i]) {
      if (element.identificador == idV) {
        return true;
      }
    }
  }
  return false;
}
