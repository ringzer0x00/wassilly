let d = "/home/ringzero/gitrepos/wassilly/test/wasm/microbenchmarks/"
let p path = Interpreter.Analysis.analyze path
(*"./tc/fib.wasm"*)

let t =
  [
    ("entry-point-start/main.wasm", [ (0, 1) ]);
    ("direct-call-simple/main.wasm", [ (0, 1) ]);
    ("indirect-call-index-expr-memory-mutable/main.wasm", [ (0, 1) ]);
    ("direct-call-transitive/main.wasm", [ (0, 1); (1, 2) ]);
    ("indirect-call-func-in-table/main.wasm", [ (0, 1) ]);
    ("indirect-call-index-expr-const/main.wasm", [ (0, 1) ]);
    ("indirect-call-index-expr-double-load/main.wasm", [ (0, 1) ]);
    ( "indirect-call-index-expr-interprocedural-param/main.wasm",
      [ (0, 1); (1, 2) ] );
    ( "indirect-call-index-expr-interprocedural-result/main.wasm",
      [ (0, 1); (0, 2) ] );
    ("indirect-call-index-expr-load-const-addr/main.wasm", [ (0, 1) ]);
    ( "indirect-call-index-expr-load-interprocedural-param/main.wasm",
      [ (0, 1); (1, 2) ] );
    ( "indirect-call-index-expr-load-interprocedural-result/main.wasm",
      [ (0, 1); (0, 2) ] );
    ("indirect-call-index-expr-local/main.wasm", [ (0, 2) ]);
    ("indirect-call-index-expr-mask/main.wasm", [ (0, 1); (0, 2) ]);
    ("indirect-call-index-expr-memory-mutable/main.wasm", [ (0, 1) ]);
    ("indirect-call-type-based/main.wasm", [ (0, 1) ]);
  ]

let ops =
  List.iter
    (fun (prog, e) ->
      Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
      let got = Fixpoint.Callgraph.CallGraph.edges (snd (p (d ^ prog))) in
      if got = e == false then (
        Printf.printf "got:\n";
        List.iter (fun (x, y) -> Printf.printf "%i->%i;" x y) got;
        Printf.printf "when expecting... @ %s\n" prog;
        List.iter (fun (x, y) -> Printf.printf "%i->%i;" x y) e;
        assert false)
      else assert true)
    t
