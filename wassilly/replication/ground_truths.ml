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
    ("host-reachable-table-export", ([ 0; 1; 2 ], [ (0, 2); (1, 0) ]), Some "");
    ("host-reachable-table-import", ([ 0; 1; 2 ], [ (0, 2); (1, 0) ]), Some "");
    ("host-code-table-mutable", ([ 0; 1; 2 ], [ (0, 2) ]), Some "");
    ("table-init-offset-imported-global", ([ 0; 1 ], [ (0, 1) ]), Some "");
    ("memory-init-offset-imported-global", ([ 0; 1 ], [ (0, 1) ]), Some "");
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
