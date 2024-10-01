let d = "/home/ringzero/gitrepos/wassilly/test/wasm/microbenchmarks/"

let p path =
  Interpreter.Analysis.callgraph_analysis' (d ^ path ^ "/main.wasm") ""
(*"./tc/fib.wasm"*)

let got = Fixpoint.Callgraph.CallGraph.edges

let%test "entry-point-start" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  got (p "entry-point-start") = [ (0, 1) ]

let%test "direct-call-simple" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  got (p "direct-call-simple") = [ (0, 1) ]

let%test "indirect-call-index-expr-memory-mutable" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  got (p "indirect-call-index-expr-memory-mutable") = [ (0, 1) ]

let%test "direct-call-transitive" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  got (p "direct-call-transitive") = [ (0, 1); (1, 2) ]

let%test "indirect-call-func-in-table" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  got (p "indirect-call-func-in-table") = [ (0, 1) ]

let%test "indirect-call-index-expr-const" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  got (p "indirect-call-index-expr-const") = [ (0, 1) ]

let%test "indirect-call-index-expr-interprocedural-param" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  got (p "indirect-call-index-expr-interprocedural-param") = [ (0, 1); (1, 2) ]

let%test "indirect-call-index-expr-local" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  got (p "indirect-call-index-expr-local") = [ (0, 2) ]

let%test "indirect-call-index-expr-mask" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  got (p "indirect-call-index-expr-mask") = [ (0, 1); (0, 2) ]

let%test "indirect-call-index-expr-memory-mutable" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  got (p "indirect-call-index-expr-memory-mutable") = [ (0, 1) ]

let%test "indirect-call-type-based" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  got (p "indirect-call-type-based") = [ (0, 1) ]

let%test "indirect-call-index-expr-load-interprocedural-result" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  got (p "indirect-call-index-expr-load-interprocedural-result")
  = [ (0, 1); (0, 2) ]

let%test "indirect-call-index-expr-load-interprocedural-param" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  got (p "indirect-call-index-expr-load-interprocedural-param")
  = [ (0, 1); (1, 2) ]

let%test "indirect-call-index-expr-load-const-addr" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  got (p "indirect-call-index-expr-load-const-addr") = [ (0, 1) ]

let%test "indirect-call-index-expr-double-load" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  got (p "indirect-call-index-expr-double-load") = [ (0, 1) ]

let%test "entry-point-wasi" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  got (p "entry-point-wasi") = [ (0, 1) ]

(* TODO
   let%test "cpp-vtable-layout-source-type-info/main.wasm" =
     Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
     got (p "cpp-vtable-layout-source-type-info/main.wasm") = []
*)
