let d = "/home/ringzero/gitrepos/wassilly/test/wasm/microbenchmarks/"

let p path =
  Interpreter.Analysis.callgraph_analysis'
    (d ^ path ^ "/main.wasm")
    (d ^ path ^ "/spec.wassilly")

let got = Datastructures.Callgraph.CallGraph.edges

let%test "memory-init-offset-imported-global" =
  Interpreter.Eval.cg := Datastructures.Callgraph.CallGraph.phi;
  got (p "memory-init-offset-imported-global") = [ (0, 1) ]

let%test "direct-call-imported-func" =
  Interpreter.Eval.cg := Datastructures.Callgraph.CallGraph.phi;
  got (p "direct-call-imported-func") = [ (1, 0) ]

let%test "table-init-offset-imported-global" =
  Interpreter.Eval.cg := Datastructures.Callgraph.CallGraph.phi;
  got (p "table-init-offset-imported-global") = [ (0, 1) ]

let%test "host-callbacks-exports" =
  Interpreter.Eval.cg := Datastructures.Callgraph.CallGraph.phi;
  got (p "host-callbacks-exports") = [ (0, 2); (1, 0); (2, 4); (3, 5) ]

let%test "host-reachable-table-export" =
  Interpreter.Eval.cg := Datastructures.Callgraph.CallGraph.phi;
  got (p "host-reachable-table-export") = [ (0, 2); (1, 0) ]

let%test "host-reachable-table-import" =
  Interpreter.Eval.cg := Datastructures.Callgraph.CallGraph.phi;
  got (p "host-reachable-table-import") = [ (0, 3); (1, 0) ]

let%test "MATTIA-host-code-table-mutable" =
  Interpreter.Eval.cg := Datastructures.Callgraph.CallGraph.phi;
  Datastructures.Callgraph.CallGraph.print (p "MATTIA-host-code-table-mutable");
  got (p "MATTIA-host-code-table-mutable") = [ (1, 0); (1, 3) ]

let%test "host-code-table-mutable" =
  Interpreter.Eval.cg := Datastructures.Callgraph.CallGraph.phi;
  got (p "host-code-table-mutable") = [ (0, 2) ]

let%test "MATTIA-indirect-call-index-expr-load-const-exported-memory-mutable" =
  Interpreter.Eval.cg := Datastructures.Callgraph.CallGraph.phi;
  got (p "MATTIA-indirect-call-index-expr-load-const-exported-memory-mutable")
  = [ (0, 1) ]

let%test "cpp-vtable-layout-source-type-info" =
  Interpreter.Eval.cg := Datastructures.Callgraph.CallGraph.phi;
  got (p "cpp-vtable-layout-source-type-info") = []
