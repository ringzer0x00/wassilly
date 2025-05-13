let d = "../../../../../test/wasm/microbenchmarks/"

let edges e =
  Datastructures.Callgraph.Ga.edges e |> Soundcomplete.EdgesSet.of_list

let vertices v =
  Datastructures.Callgraph.Ga.vertices v |> Soundcomplete.VerticesSet.of_list

let p path spec =
  Interpreter.Eval.cg := Datastructures.Callgraph.Ga.phi;
  let g =
    match spec with
    | None ->
        Interpreter.Analysis.callgraph_analysis' (d ^ path ^ "/main.wasm") ""
    | Some _ ->
        Interpreter.Analysis.callgraph_analysis'
          (d ^ path ^ "/main.wasm")
          (d ^ path ^ "/spec.wassilly")
  in
  (vertices g, edges g)

let tc_aux tcn spec gt =
  Format.printf "Benchmark[%s]:\n" tcn;
  let v, e = p tcn spec in
  let vgt, egt = gt in
  let s = Soundcomplete.sound e egt v vgt in
  let c = Soundcomplete.complete e egt v vgt in
  let e = Soundcomplete.exact e egt v vgt in
  Format.printf "\tSound:%b; Complete:%b; Exact:%b\n\n" s c e;
  Format.print_flush ();
  (s, c, e)

open Ground_truths

let fst (a, _, _) = a
let snd (_, a, _) = a
let trd (_, _, a) = a

let%test "soundness" =
  TestMap.for_all
    (fun name (gt, hasSpec) -> tc_aux name hasSpec gt |> fst)
    gts_map
(*
let%test "completeness" =
  TestMap.for_all
    (fun name (gt, hasSpec) -> tc_aux name hasSpec gt |> snd)
    gts_map

let%test "exact" =
  TestMap.for_all
    (fun name (gt, hasSpec) -> tc_aux name hasSpec gt |> trd)
    gts_map*)
(*
let%test "entry-point-start" =
  let tcn = "entry-point-start" in
  tc_aux tcn None entry_point_start

let%test "direct-call-simple" =
  let tcn = "direct-call-simple" in
  tc_aux tcn None direct_call_simple

let%test "direct-call-transitive" =
  let tcn = "direct-call-transitive" in
  tc_aux tcn None direct_call_transitive

let%test "indirect-call-index-expr-memory-mutable" =
  let tcn = "indirect-call-index-expr-memory-mutable" in
  tc_aux tcn None indirect_call_index_expr_memory_mutable

let%test "indirect-call-func-in-table" =
  let tcn = "indirect-call-index-expr-memory-mutable" in
  tc_aux tcn None indirect_call_index_expr_memory_mutable

let%test "indirect-call-index-expr-const" =
  let tcn = "indirect-call-index-expr-const" in
  tc_aux tcn None indirect_call_index_expr_const

let%test "indirect-call-index-expr-interprocedural-param" =
  let tcn = "indirect-call-index-expr-interprocedural-param" in
  tc_aux tcn None indirect_call_index_expr_interprocedural_param

let%test "indirect-call-index-expr-local" =
  let tcn = "indirect-call-index-expr-local" in
  tc_aux tcn None indirect_call_index_expr_local
*)
