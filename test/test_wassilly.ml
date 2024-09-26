module WASM = Test_wasm

(*open OUnit2
  let _ = run_test_tt_main MON.all
    let _ = run_test_tt_main SLT.all*)

(*let _ = WASM.Test_wasm_closed.ops*)
let _ = WASM.Test_wasm_open.ops

(*
module P = Test_parser

let _ = P.r ()*)