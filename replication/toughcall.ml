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

let _tc_aux tcn spec gt =
  Format.printf "[%s]:\t\t\t" tcn;
  let v, e = p tcn spec in
  let vgt, egt = gt in
  let s = Soundcomplete.sound e egt v vgt in
  let c = Soundcomplete.complete e egt v vgt in
  let e = Soundcomplete.exact e egt v vgt in
  Format.printf "\tSound:%b; Complete:%b; Exact:%b\n" s c e;
  Format.print_flush ();
  (s, c, e)

let tc_aux tcn spec gt =
  let v, e = p tcn spec in
  let vgt, egt = gt in
  let s = Soundcomplete.sound e egt v vgt in
  let c = Soundcomplete.complete e egt v vgt in
  let ex = Soundcomplete.exact e egt v vgt in

  (* Stampa intestazione se serve – può essere spostata all'esterno per stamparla una sola volta *)
  (* Format.printf "%-20s | %-7s | %-9s | %-6s\n" "Test Case" "Sound" "Complete" "Exact"; *)
  (* Format.printf "%s\n" (String.make 52 '-'); *)

  (* Stampa tabellare *)
  let topbot x = if x then "T" else "F" in
  let s_s, c_s, ex_s = (topbot s, topbot c, topbot ex) in
  Format.printf "%-55s | %-1s | %-1s | %-1s\n" tcn s_s c_s ex_s;
  Format.print_flush ();
  (s, c, ex)

open Ground_truths

let fst (a, _, _) = a
let snd (_, a, _) = a
let trd (_, _, a) = a

let%test "Soundness" =
  Format.print_flush ();
  Format.print_newline ();
  Format.printf "%-55s | %-1s | %-1s | %-1s\n" "TestCase" "S" "C" "E";
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
