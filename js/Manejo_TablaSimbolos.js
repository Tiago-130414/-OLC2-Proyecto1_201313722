function generarTablas(ambitos) {
  var div = document.getElementById("htmlTxt");
  var cad = " ";
  cad = recorrerAmbitos(ambitos);
  div.innerHTML = cad;
}

function recorrerAmbitos(ambitos) {
  var cad = "";
  for (var elementos of ambitos) {
    cad += ' <div class="table-wrapper-scroll-y my-custom-scrollbar">\n';
    cad += '<table class="table table-bordered table-striped mb-0">\n';
    cad += "<thead>\n<tr>\n";
    cad +=
      '<th scope="col">#</th>\n<th scope="col">Nombre</th>\n<th scope="col">Tipo</th>\n<th scope="col">Ambito</th>\n<th scope="col">Linea</th>\n';
    cad += "</tr>\n";
    cad += '<tbody id="tablaS">';
    cad += LlenarVariablesTS(elementos);
    cad += "</tbody>";
    cad += "</table>";
    cad += "</div>";
  }
  return cad;
}

function LlenarVariablesTS(vector) {
  var contarVar = 0;
  var nombre = "";
  var tipo = "";
  var ambito = "";
  var fila = 0;
  var htmlTags = "";

  vector.forEach(function (elemento) {
    nombre = elemento.identificador;
    tipo = elemento.tipo;
    ambito = elemento.ambito;
    fila = elemento.fila;
    htmlTags +=
      "<tr>" +
      "<td>" +
      (contarVar + 1) +
      "</td>" +
      "<td>" +
      nombre +
      "</td>" +
      "<td>" +
      tipo +
      "</td>" +
      "<td>" +
      ambito +
      "</td>" +
      "<td>" +
      fila +
      "</td>" +
      "</tr>\n";
    contarVar++;
  });
  return htmlTags;
}
