(* the edges and vertices considered are only the ones reachable from the entrypoints. *)
open Soundcomplete

let to_vertex = Int32.of_int
let to_edge (f, t) = (Int32.of_int f, Int32.of_int t)

let make_gt (vertices, edges) =
  let v' = List.map to_vertex vertices in
  let e' = List.map to_edge edges in
  (VerticesSet.of_list v', EdgesSet.of_list e')

module TestMap = Map.Make (String)

let gts_comprehensive_closed =
  [
    ("direct-call-simple", ([ 0; 1 ], [ (0, 1) ]), None);
    ("direct-call-transitive", ([ 0; 1 ], [ (0, 1) ]), None);
    ("direct-call-imported-func", ([ 0; 1 ], [ (1, 0) ]), Some "");
    ("entry-point-start", ([ 0; 1 ], [ (0, 1) ]), None);
    ("entry-point-wasi", ([ 0; 1 ], [ (0, 1) ]), None);
    ( "host-callbacks-exports",
      ([ 0; 1; 2; 3; 4; 5 ], [ (0, 2); (1, 0); (2, 4); (3, 5) ]),
      Some "" );
    (*host-reachable-table-export*)
    (*host-reachable-table-import*)
    (*host-code-table-mutable*)
    (*table-init-offset-imported-global*)
    (*memory-init-offset-imported-global*)
    ("indirect-call-func-in-table", ([ 0; 1 ], [ (0, 1) ]), None);
    ("indirect-call-type-based", ([ 0; 1 ], [ (0, 1) ]), None);
    ("indirect-call-index-expr-const", ([ 0; 1 ], [ (0, 1) ]), None);
    ("indirect-call-index-expr-local", ([ 0; 2 ], [ (0, 2) ]), None);
    ("indirect-call-index-expr-mask", ([ 0; 1; 2 ], [ (0, 1); (0, 2) ]), None);
    ( "indirect-call-index-expr-interprocedural-param",
      ([ 0; 1; 2 ], [ (0, 1); (1, 2) ]),
      None );
    ( "indirect-call-index-expr-interprocedural-result",
      ([ 0; 1; 2 ], [ (0, 1); (0, 2) ]),
      None );
    ("indirect-call-index-expr-load-const-addr", ([ 0; 1 ], [ (0, 1) ]), None);
    ( "indirect-call-index-expr-load-interprocedural-param",
      ([ 0; 1; 2 ], [ (0, 1); (1, 2) ]),
      None );
    ( "indirect-call-index-expr-load-interprocedural-result",
      ([ 0; 1; 2 ], [ (0, 1); (0, 2) ]),
      None );
    ("indirect-call-index-expr-double-load", ([ 0; 1 ], [ (0, 1) ]), None);
    ("indirect-call-index-expr-memory-mutable", ([ 0; 1 ], [ (0, 1) ]), None);
    ( "cpp-vtable-layout-source-type-info",
      (Data_test.vtables_rf, Data_test.vtables_gt),
      Some "" );
  ]

let gts_map =
  List.map (fun (n, gt, s) -> (n, (make_gt gt, s))) gts_comprehensive_closed
  |> List.to_seq |> TestMap.of_seq

(*

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


(*requiring specification*)

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
  Datastructures.Callgraph.print_graph Format.std_formatter cg;
  edges cg = Data_test.vtables_gt && reachable cg = Data_test.vtables_rf
*)
