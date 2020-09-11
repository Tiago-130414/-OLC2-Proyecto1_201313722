function AnalizarCodigo() {
  var texto = Codigo.getValue();
  Reporte_Errores.parse(texto);
  alert("Analizado");
}
