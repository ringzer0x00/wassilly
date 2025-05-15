let d = "../../../../../test/wasm/microbenchmarks/"

let p path =
  Interpreter.Analysis.callgraph_analysis'
    (d ^ path ^ "/main.wasm")
    (d ^ path ^ "/spec.wassilly")

    let edges = Datastructures.Callgraph.Ga.edges_as_int
    let reachable = Datastructures.Callgraph.Ga.vertices_as_int


let%test "MATTIA-host-code-table-mutable" =
Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
edges (p "MATTIA-host-code-table-mutable") = [ (1, 0); (1, 3) ]

let%test "MATTIA-indirect-call-index-expr-load-const-exported-memory-mutable" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg =
    p "MATTIA-indirect-call-index-expr-load-const-exported-memory-mutable"
  in
  edges cg = [ (0, 1) ]

  