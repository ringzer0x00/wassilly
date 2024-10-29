let d = "/home/ringzero/gitrepos/wassilly/test/wasm/microbenchmarks/"

let p path =
  Interpreter.Analysis.callgraph_analysis'
    (d ^ path ^ "/main.wasm")
    (d ^ path ^ "/spec.wassilly")

let got = Datastructures.Callgraph.Ga.edges_as_int

let%test "memory-init-offset-imported-global" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  got (p "memory-init-offset-imported-global") = [ (0, 1) ] (*[0;1]*)

let%test "direct-call-imported-func" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  got (p "direct-call-imported-func") = [ (1, 0) ] (*[0;1]*)

let%test "table-init-offset-imported-global" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  got (p "table-init-offset-imported-global") = [ (0, 1) ]

let%test "host-callbacks-exports" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  got (p "host-callbacks-exports") = [ (0, 2); (1, 0); (2, 4); (3, 5) ] (*[0;1;2;3;4;5]*)

let%test "host-reachable-table-export" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  got (p "host-reachable-table-export") = [ (0, 2); (1, 0) ] (*[0;1;2]*)

let%test "host-reachable-table-import" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  got (p "host-reachable-table-import") = [ (0, 2); (1, 0) ] (*[0;1;2]*)

let%test "MATTIA-host-code-table-mutable" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  got (p "MATTIA-host-code-table-mutable") = [ (1, 0); (1, 3) ]

let%test "host-code-table-mutable" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  got (p "host-code-table-mutable") = [ (0, 2) ] (*[0;1;2]*)

let%test "MATTIA-indirect-call-index-expr-load-const-exported-memory-mutable" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  got (p "MATTIA-indirect-call-index-expr-load-const-exported-memory-mutable")
  = [ (0, 1) ]
(* disabled because my shit memory implementation takes a shitload of time to execute this
let%test "cpp-vtable-layout-source-type-info" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let a = p "cpp-vtable-layout-source-type-info" in
  got a = Data_test.vtables_gt
*)