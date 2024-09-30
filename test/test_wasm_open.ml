let d = "/home/ringzero/gitrepos/wassilly/test/wasm/microbenchmarks/"

let p path =
  Interpreter.Analysis.callgraph_analysis' (d ^ path ^ "/main.wasm")
    (d ^ path ^ "/spec.wassilly")
(*"./tc/fib.wasm"*)

let got = Fixpoint.Callgraph.CallGraph.edges

let%test "memory-init-offset-imported-global" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  got (p "memory-init-offset-imported-global") = [ (0, 1) ]

let t =
  [
    (*imports*)
    (*("memory-init-offset-imported-global", [ (0, 1) ]);*)
    (*("cpp-vtable-layout-source-type-info", []);*)
    (*("direct-call-imported-func", [ (1, 0) ]);*)
    (*("entry-point-wasi/main.wasm", []);*)
    (*("host-callbacks-exports", []);*)
    (*("host-code-table-mutable", []);*)
    (*("host-reachable-table-export", []);*)
    (*("host-reachable-table-import", []);*)
    (*("table-init-offset-imported-global", []);*)
  ]
(*
let ops =
  List.iter
    (fun (prog, e) ->
      Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
      let got = Fixpoint.Callgraph.CallGraph.edges (p (d ^ prog)) in
      if got = e == false then (
        Printf.printf "got:\n";
        List.iter (fun (x, y) -> Printf.printf "%i->%i;" x y) got;
        Printf.printf "when expecting... @ %s\n" prog;
        List.iter (fun (x, y) -> Printf.printf "%i->%i;" x y) e;
        assert false)
      else assert true)
    t
*)