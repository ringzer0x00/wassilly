let d = "../../../../../test/wasm/microbenchmarks/"

let p path =
  Interpreter.Analysis.callgraph_analysis' (d ^ path ^ "/main.wasm") ""

let edges = Datastructures.Callgraph.Ga.edges_as_int
let reachable = Datastructures.Callgraph.Ga.vertices_as_int

let%test "entry-point-start" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "entry-point-start" in
  edges cg = [ (0, 1) ] && reachable cg = [ 0; 1 ]

let%test "direct-call-simple" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "direct-call-simple" in
  edges cg = [ (0, 1) ] && reachable cg = [ 0; 1 ]

let%test "indirect-call-index-expr-memory-mutable" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "indirect-call-index-expr-memory-mutable" in
  edges cg = [ (0, 1) ] && reachable cg = [ 0; 1 ]

let%test "direct-call-transitive" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "direct-call-transitive" in
  edges cg = [ (0, 1); (1, 2) ] && reachable cg = [ 0; 1; 2 ]

let%test "indirect-call-func-in-table" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "indirect-call-func-in-table" in
  edges cg = [ (0, 1) ] && reachable cg = [ 0; 1 ]

let%test "indirect-call-index-expr-const" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "indirect-call-index-expr-const" in
  edges cg = [ (0, 1) ] && reachable cg = [ 0; 1 ]

let%test "indirect-call-index-expr-interprocedural-param" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "indirect-call-index-expr-interprocedural-param" in
  edges cg = [ (0, 1); (1, 2) ] && reachable cg = [ 0; 1; 2 ]

let%test "indirect-call-index-expr-local" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "indirect-call-index-expr-local" in
  edges cg = [ (0, 2) ] && reachable cg = [ 0; 2 ]

let%test "indirect-call-index-expr-mask" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "indirect-call-index-expr-mask" in
  edges cg = [ (0, 1); (0, 2) ] && reachable cg = [ 0; 1; 2 ]

let%test "indirect-call-index-expr-memory-mutable" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "indirect-call-index-expr-memory-mutable" in
  edges cg = [ (0, 1) ] && reachable cg = [ 0; 1 ]

let%test "indirect-call-type-based" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "indirect-call-type-based" in
  edges cg = [ (0, 1) ] && reachable cg = [ 0; 1 ]

let%test "indirect-call-index-expr-load-interprocedural-result" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "indirect-call-index-expr-load-interprocedural-result" in
  edges cg = [ (0, 1); (0, 2) ] && reachable cg = [ 0; 1; 2 ]

let%test "indirect-call-index-expr-load-interprocedural-param" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "indirect-call-index-expr-load-interprocedural-param" in
  edges cg = [ (0, 1); (1, 2) ] && reachable cg = [ 0; 1; 2 ]

let%test "indirect-call-index-expr-load-const-addr" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "indirect-call-index-expr-load-const-addr" in
  edges cg = [ (0, 1) ] && reachable cg = [ 0; 1 ]

let%test "indirect-call-index-expr-double-load" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "indirect-call-index-expr-double-load" in
  edges cg = [ (0, 1) ] && reachable cg = [ 0; 1 ]

let%test "entry-point-wasi" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "entry-point-wasi" in
  edges cg = [ (0, 1) ] && reachable cg = [ 0; 1 ]
