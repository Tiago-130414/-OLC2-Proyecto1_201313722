//POST QUE ENVIA DATOS DEL ARCHIVO 1
function conexion() {
  var pestanaAct = document.getElementsByClassName("tab-pane fade in active");
  var cajatxt = pestanaAct[0].getAttribute("id");
  var txt = document.getElementById("text" + cajatxt);
  var obtenerTexto = txt.value;
  console.log(obtenerTexto);

  var url = "http://localhost:3000/api/index/Archivo1";
  var data = { texto: obtenerTexto };

  fetch(url, {
    method: "POST",
    body: JSON.stringify(data),
    headers: {
      "Content-Type": "application/json",
    },
  })
    .then((res) => res.json())
    .catch((error) => console.error("Error:", error))
    .then((response) => alert("Success:", response.prueba));

  recuperarErrL();
  recuperarErrS();
}

//POST QUE ENVIA DATOS DEL ARCHIVO 2
function conexion2() {
  var pestanaAct = document.getElementsByClassName("tab-pane fade in active");
  var cajatxt = pestanaAct[0].getAttribute("id");
  var txt = document.getElementById("text" + cajatxt);
  var obtenerTexto = txt.value;
  console.log(obtenerTexto);

  var url = "http://localhost:3000/api/index/Archivo2";
  var data = { texto: obtenerTexto };

  fetch(url, {
    method: "POST",
    body: JSON.stringify(data),
    headers: {
      "Content-Type": "application/json",
    },
  })
    .then((res) => res.json())
    .catch((error) => console.error("Error:", error))
    .then((response) => alert("Success:", response.prueba));
}

//GET PARA RECUPERAR REPORTE CLASES COPIA
function reporteClasesCopia() {
  var url = "http://localhost:3000/api/index/RetornarReporteClasesCopia";
  var txt = document.getElementById("salidaTxt");
  fetch(url)
    .then(function (response) {
      return response.json();
    })
    .then(function (myJson) {
      txt.innerHTML = myJson.txt;
    });
}

//GET PARA RECUPERAR REPORTE FUNCIONES COPIA
function recuperarFuncionesCopia() {
  var url = "http://localhost:3000/api/index/RetornarReporteFuncionesCopia";
  var txt = document.getElementById("salidaTxt");
  fetch(url)
    .then(function (response) {
      return response.json();
    })
    .then(function (myJson) {
      txt.innerHTML = myJson.txt;
    });
}
//GET PARA RECUPERAR REPORTE VARIABLES COPIA
function recuperarVariablesCopia() {
  var url = "http://localhost:3000/api/index/RetornarReporteVariablesCopia";
  var txt = document.getElementById("salidaTxt");
  fetch(url)
    .then(function (response) {
      return response.json();
    })
    .then(function (myJson) {
      txt.innerHTML = myJson.txt;
    });
}

//GET REPORTE AST
function recuperarArbolReporte() {
  var txt = document.getElementById("salidaTxt");
  var url = "http://localhost:3000/api/index/ReportArbol";

  fetch(url)
    .then(function (response) {
      return response.json();
    })
    .then(function (myJson) {
      createJSTree(myJson);
      alert("Reporte AST !Listo!");
    });
}

//GET ERRORES LEXICOS
function recuperarErrL() {
  var txt = document.getElementById("erroresLexicosTxt");
  var url = "http://localhost:3000/api/index/ErroresL";
  txt.innerHTML = "";
  var errores = "";
  fetch(url)
    .then(function (response) {
      return response.json();
    })
    .then(function (myJson) {
      errores = myJson.ErroresL;
      txt.innerHTML = errores;
    });
}

//GET ERRORES SINTACTICOS
function recuperarErrS() {
  var txt = document.getElementById("erroresSintacticosTxt");
  var url = "http://localhost:3000/api/index/ErroresS";
  txt.innerHTML = "";
  var errores = "";
  fetch(url)
    .then(function (response) {
      return response.json();
    })
    .then(function (myJson) {
      //var json = JSON.stringify(myJson, null, 2);
      errores = myJson.ErroresSintac;
      txt.innerHTML = errores;
    });
}

//GET ERRORES SINTACTICOS Y LEXICOS
function recuperarErrLS() {
  var url = "http://localhost:3000/api/index/ErroresLS";
  fetch(url)
    .then(function (response) {
      return response.json();
    })
    .then(function (myJson) {
      leerJsonErroresLS(myJson.ELS);
    });
}

/*------------------------------------------------  REPORTE CLASE COPIA  ------------------------------------------------*/

/*
Reporte de Clases Copia
Este reporte deberá mostrar un listado de todas las clases que se consideren como copia,
para considerar una clase como clase copia se deberá de verificar que tenga el mismo
nombre y los mismos métodos y/o funciones. Este reporte debe mostrar el nombre de la
clase, cantidad de métodos y/o funciones que contiene.
*/
