function ejJson() {
  var texto = Codigo.getValue();
  var vector = Reporte_Errores.parse(texto);
  if (vector.Arbol.length > 0) {
    ejecutarArchivo(vector.Arbol);
  } else {
    var txt = Consola.getValue();
    Consola.setValue("!Problema al ejecutar codigo!");
  }
}

function ejecutarArchivo(json) {
  for (var element of json) {
    if (element.tipoInstruccion == "CONSOLE") {
      setter(element.tipoInstruccion);
      ejecutarImprimir(element.contenido);
    }
  }
}

function ejecutarImprimir(elemento) {
  var result = leerExp(elemento);
  console.log(result);
}

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
    return { tipo: exp.tipo, valor: exp.valor, fila: exp.fila };
  } else if (exp.tipo == "CADENA") {
    return { tipo: exp.tipo, valor: exp.valor, fila: exp.fila };
  } else if (exp.tipo == "BOOLEAN") {
    return { tipo: exp.tipo, valor: exp.valor, fila: exp.fila };
  } else if (exp.tipo == "UNDEFINED") {
    return { tipo: exp.tipo, valor: exp.valor, fila: exp.fila };
  } else if (exp.tipo == "IDENTIFICADOR") {
    return { tipo: exp.tipo, valor: exp.valor, fila: exp.fila };
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
      return { tipo: tip, valor: op };
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
      return { tipo: tip, valor: op };
    }
  } else if (opDer.tipo == "BOOLEAN") {
    if (opIzq.tipo == "CADENA") {
      var op = opIzq.valor + opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, valor: op };
    }
  } else if (opDer.tipo == "UNDEFINED") {
    if (opIzq.tipo == "CADENA") {
      var op = opIzq.valor + opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, valor: op };
    }
  }
  return {
    tipo: "Error Semantico",
    desc: "valor incompatible con operacion aritmetica, en la fila: ",
    fila: opDer.fila,
  };
}

function validarTiposOP(opIzq, opDer, tipOp) {
  if (opIzq.tipo == "NUMERO" && opDer.tipo == "NUMERO") {
    if (tipOp == "RES") {
      var op = opIzq.valor - opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, valor: op };
    } else if (tipOp == "MULT") {
      var op = opIzq.valor * opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, valor: op };
    } else if (tipOp == "DIV") {
      var op = opIzq.valor / opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, valor: op };
    } else if (tipOp == "POT") {
      var op = opIzq.valor ** opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, valor: op };
    } else if (tipOp == "MOD") {
      var op = opIzq.valor % opDer.valor;
      var tip = asignarTipo(typeof op);
      return { tipo: tip, valor: op };
    }
  }
  return {
    tipo: "Error Semantico",
    desc: "valor incompatible con operacion aritmetica, en la fila: ",
    fila: opDer.fila,
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
    tipo: "Error Semantico",
    desc: "valor incompatible con operacion relacional, en la fila: ",
    fila: opDer.fila,
  };
}

function validarTipoIgIg(opIzq, opDer) {
  if (
    opIzq.tipo != "IDENTIFICADOR" &&
    opIzq.tipo != "UNDEFINED" &&
    opDer.tipo != "IDENTIFICADOR" &&
    opDer.tipo != "UNDEFINED"
  ) {
    if (opIzq.valor == opDer.valor) {
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
    desc: "valor incompatible con operacion relacional, en la fila: ",
    fila: opDer.fila,
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
    tipo: "Error Semantico",
    desc: "valor incompatible con operacion relacional, en la fila: ",
    fila: opDer.fila,
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
    tipo: "Error Semantico",
    desc: "valor incompatible con operacion negacion, en la fila: ",
    fila: opI.fila,
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
