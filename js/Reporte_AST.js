function reporteAST() {
  var texto = Codigo.getValue();
  var arbol = AnalisisLS.parse(texto);
  d3.select("#ArbolAST1")
    .graphviz()
    .renderDot(
      "digraph{" +
        "ordering=out;" +
        "	graph [splines=compound,nodesep=0.5];" +
        "graph [nodesep=1];" +
        'node [shape = record, style="rounded,filled", fillcolor="orange:red",width=0.7,height=0.5];' +
        arbol +
        "}"
    );
  alert("Reporte AST Generado!");
}
