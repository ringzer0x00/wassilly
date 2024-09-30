let d = "/home/ringzero/gitrepos/wassilly/test/wasm/microbenchmarks/"

let p path =
  Interpreter.Analysis.callgraph_analysis' (d ^ path ^ "/main.wasm")
    (d ^ path ^ "/spec.wassilly")
(*"./tc/fib.wasm"*)

let got = Fixpoint.Callgraph.CallGraph.edges

let%test "memory-init-offset-imported-global" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  got (p "memory-init-offset-imported-global") = [ (0, 1) ]

  let%test "direct-call-imported-func" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  got (p "direct-call-imported-func") = [ (1, 0) ]
  
let t =
  [
    (*imports*)
    (*("", [ (1, 0) ]);*)
    (*("host-callbacks-exports", []);*)
    (*("host-code-table-mutable", []);*)
    (*("host-reachable-table-export", []);*)
    (*("host-reachable-table-import", []);*)
    (*("table-init-offset-imported-global", []);*)
  ]
