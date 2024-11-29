let d = "../../../../../test/wasm/microbenchmarks/"

let p path =
  Interpreter.Analysis.callgraph_analysis'
    (d ^ path ^ "/main.wasm")
    (d ^ path ^ "/spec.wassilly")

let edges = Datastructures.Callgraph.Ga.edges_as_int
let reachable = Datastructures.Callgraph.Ga.vertices_as_int

let%test "memory-init-offset-imported-global" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "memory-init-offset-imported-global" in
  edges cg = [ (0, 1) ] && reachable cg = [ 0; 1 ]

let%test "direct-call-imported-func" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "direct-call-imported-func" in
  edges cg = [ (1, 0) ] && reachable cg = [ 0; 1 ]

let%test "table-init-offset-imported-global" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "table-init-offset-imported-global" in
  edges cg = [ (0, 1) ] && reachable cg = [ 0; 1 ]

let%test "host-callbacks-exports" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "host-callbacks-exports" in
  edges cg = [ (0, 2); (1, 0); (2, 4); (3, 5) ]
  && reachable cg = [ 0; 1; 2; 3; 4; 5 ]

let%test "host-reachable-table-export" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "host-reachable-table-export" in
  edges cg = [ (0, 2); (1, 0) ] && reachable cg = [ 0; 1; 2 ]

let%test "host-reachable-table-import" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "host-reachable-table-import" in
  edges cg = [ (0, 2); (1, 0) ] && reachable cg = [ 0; 1; 2 ]

let%test "host-code-table-mutable" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "host-code-table-mutable" in
  edges cg = [ (0, 2) ] && reachable cg = [ 0; 1; 2 ]

let%test "cpp-vtable-layout-source-type-info" =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let cg = p "cpp-vtable-layout-source-type-info" in
  edges cg = Data_test.vtables_gt && reachable cg = Data_test.vtables_rf
