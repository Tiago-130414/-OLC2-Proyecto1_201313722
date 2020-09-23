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
    var opIzq = leerExp(exp.opIzq).valor;
    var opDer = leerExp(exp.opDer).valor;
    if (exp.tipo == "OPERACION_SUMA") {
      var op = opIzq + opDer;
      return { tipo: "NUMERO", valor: op };
    } else if (exp.tipo == "OPERACION_RESTA") {
      var op = opIzq - opDer;
      return { tipo: "NUMERO", valor: op };
    } else if (exp.tipo == "OPERACION_MULTIPLICACION") {
      var op = opIzq * opDer;
      return { tipo: "NUMERO", valor: op };
    } else if (exp.tipo == "OPERACION_DIVISION") {
      var op = opIzq / opDer;
      return { tipo: "NUMERO", valor: op };
    } else if (exp.tipo == "OPERACION_EXPONENCIACION") {
      var op = opIzq ** opDer;
      return { tipo: "NUMERO", valor: op };
    } else if (exp.tipo == "OPERACION_MODULO") {
      var op = opIzq % opDer;
      return { tipo: "NUMERO", valor: op };
    }
  } else if (exp.tipo == "NUMERO") {
    return { tipo: exp.tipo, valor: exp.valor };
  }
}

function setter(val) {
  var txt = Consola.getValue();
  Consola.setValue(txt + val + "\n");
}
