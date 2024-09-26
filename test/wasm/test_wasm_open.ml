let d = "/home/ringzero/gitrepos/wassilly/test/wasm/microbenchmarks/"
let p path spec = Interpreter.Analysis.callgraph_analysis' path spec
(*"./tc/fib.wasm"*)

let t =
  [
    (*("entry-point-start/main.wasm", [ (0, 1) ]);
      ("direct-call-simple/main.wasm", [ (0, 1) ]);
      ("indirect-call-index-expr-memory-mutable/main.wasm", [ (0, 1) ]);
      ("direct-call-transitive/main.wasm", [ (0, 1); (1, 2) ]);
      ("indirect-call-func-in-table/main.wasm", [ (0, 1) ]);
      ("indirect-call-index-expr-const/main.wasm", [ (0, 1) ]);
      ( "indirect-call-index-expr-interprocedural-param/main.wasm",
        [ (0, 1); (1, 2) ] );
      ("indirect-call-index-expr-local/main.wasm", [ (0, 2) ]);
      ("indirect-call-index-expr-mask/main.wasm", [ (0, 1); (0, 2) ]);
      ("indirect-call-index-expr-memory-mutable/main.wasm", [ (0, 1) ]);
      ("indirect-call-type-based/main.wasm", [ (0, 1) ]);
      ( "indirect-call-index-expr-load-interprocedural-result/main.wasm",
        [ (0, 1); (0, 2) ] );
      ( "indirect-call-index-expr-load-interprocedural-param/main.wasm",
        [ (0, 1); (1, 2) ] );
      ("indirect-call-index-expr-load-const-addr/main.wasm", [ (0, 1) ]);
      ("indirect-call-index-expr-double-load/main.wasm", [ (0, 1) ]);*)
    (*imports*)
    (*("cpp-vtable-layout-source-type-info/main.wasm", []);*)
    (*("direct-call-imported-func/main.wasm", []);*)
    ("memory-init-offset-imported-global/main.wasm", "memory-init-offset-imported-global/spec.wassilly", [(0,1)]);
    (*("entry-point-wasi/main.wasm", []);*)
    (*("host-callbacks-exports/main.wasm", []);*)
    (*("host-code-table-mutable/main.wasm", []);*)
    (*("host-reachable-table-export/main.wasm", []);*)
    (*("host-reachable-table-import/main.wasm", []);*)
    (*("table-init-offset-imported-global/main.wasm", []);*)
  ]

let ops =
  List.iter
    (fun (prog, spec, e) ->
      Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
      let got = Fixpoint.Callgraph.CallGraph.edges (p (d ^ prog) (d ^ spec)) in
      if got = e == false then (
        Printf.printf "got:\n";
        List.iter (fun (x, y) -> Printf.printf "%i->%i;" x y) got;
        Printf.printf "when expecting... @ %s\n" prog;
        List.iter (fun (x, y) -> Printf.printf "%i->%i;" x y) e;
        assert false)
      else assert true)
    t
