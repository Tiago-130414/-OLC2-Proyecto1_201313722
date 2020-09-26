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
      ejecutarDeclaracion(element, "global");
    } else if (element.tipoInstruccion == "GRAFICARTS") {
      graficar();
    } else if (element.tipoInstruccion == "ASIGNACION") {
      ejecutarAsignacion(element);
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
  console.log(result);
  if (result.tipo == "Error Semantico") {
    errorSemantico.push(result);
  } else {
    setter(result.valor);
  }
}
/////////////////////////////////////////////////INSTRUCCION DECLARACION DE VARIABLE
function ejecutarDeclaracion(elemento, ambi) {
  var mod = elemento.modificador;
  for (var ele of elemento.contenido) {
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
                ambito: ambi,
                modificador: mod,
                identificador: ele.identificador,
                tipoDato: ele.tipoDato,
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
            ambito: ambi,
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
          ambito: ambi,
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
        Error: "variable ya declarada ->" + ele.identificador,
        Fila: ele.fila,
        Columna: 0,
      });
    }
  }
}
/////////////////////////////////////////////////INSTRUCCION ASIGNACION DE VARIABLE
function ejecutarAsignacion(elemento) {}
////////////////////////////////////////////////INSTRUCCION GRAFICAR TS
function graficar() {
  generarTablas(ambitos);
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
    tipo: "Error Semantico",
    Error: "valor incompatible con operacion negacion",
    Fila: opI.fila,
    Columna: 0,
  };
}
/////////////////////////////////////////////////OPERACIONES INCREMENTO
function ejecutarIncrementoD(exp) {
  var id = lAcceso(exp.opIzq).valor;
  var el = buscarAmbId(exp, id);
  if (el.tipo != "Error Semantico") {
    if (el.modificador != "const") {
      var f = el.valor++;
      var tip = typeof el.valor;
      return { tipo: tip, valor: f, fila: el.fila };
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
}

function ejecutarIncrementoA(exp) {
  var id = lAcceso(exp.opIzq).valor;
  var el = buscarAmbId(exp, id);
  if (el.tipo != "Error Semantico") {
    if (el.modificador != "const") {
      var f = ++el.valor;
      var tip = typeof el.valor;
      return { tipo: tip, valor: f, fila: el.fila };
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
}

function ejecutarDecrementoD(exp) {
  var id = lAcceso(exp.opIzq).valor;
  var el = buscarAmbId(exp, id);
  if (el.tipo != "Error Semantico") {
    if (el.modificador != "const") {
      var f = el.valor--;
      var tip = typeof el.valor;
      return { tipo: tip, valor: f, fila: el.fila };
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
}

function ejecutarDecrementoA(exp) {
  var id = lAcceso(exp.opIzq).valor;
  var el = buscarAmbId(exp, id);
  if (el.tipo != "Error Semantico") {
    if (el.modificador != "const") {
      var f = --el.valor;
      var tip = typeof el.valor;
      return { tipo: tip, valor: f, fila: el.fila };
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
    return op[0];
  }
}
