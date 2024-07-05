open OUnit2
module SLT = Segalang_test
module MON = Test_monolith

let _ = run_test_tt_main MON.all
let _ = run_test_tt_main SLT.all
