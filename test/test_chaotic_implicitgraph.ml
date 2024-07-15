module SLT = Segalang_test
module MON = Test_monolith
module WASM = Test_wasm

(*open OUnit2
  let _ = run_test_tt_main MON.all
    let _ = run_test_tt_main SLT.all*)
let _ = WASM.r
let _ = Printf.printf "length of stack: %i" WASM.length
