var Consola = CodeMirror.fromTextArea(document.getElementById("salidaTxt"), {
  mode: "javascript",
  theme: "night",
  lineNumbers: true,
  matchBrackets: true,
  continueComments: "Enter",
  hint: true,
});
Consola.setSize("1000", "440");

var TraduccionTP = CodeMirror.fromTextArea(
  document.getElementById("traduccion"),
  {
    mode: "javascript",
    theme: "night",
    lineNumbers: true,
    matchBrackets: true,
    continueComments: "Enter",
    hint: true,
  }
);
TraduccionTP.setSize("500", "500");

var Codigo = CodeMirror.fromTextArea(document.getElementById("codigoTXT"), {
  mode: "javascript",
  theme: "night",
  lineNumbers: true,
  matchBrackets: true,
  continueComments: "Enter",
  hint: true,
});
Codigo.setSize("500", "500");
