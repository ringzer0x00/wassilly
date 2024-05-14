open OUnit2

let all : (string * test_fun) list =
  [
    (*("fib", fun _ -> assert_equal true Fib.assertion);
    ("silly", fun _ -> assert_equal true Silly.assertion);*)
    (*("fibdiv", fun _ -> assert_equal true Fibdiv.assertion);
    ("fibmix", fun _ -> assert_equal true Fibmix.assertion);
    *)("fibn", fun _ -> assert_equal true Fibn.assertion);(*
    ("fact", fun _ -> assert_equal true Fact.assertion);
    ("peano", fun _ -> assert_equal true Peano.assertion);*)
  ]

let testify (tn, tf) = tn >:: tf

let test_filter = function
  | "all" -> List.map (fun x -> testify x) all
  | _ as tname -> List.filter (fun (x, _) -> x = tname) all |> List.map testify

let tests = "test suite for analysis results" >::: test_filter "all"
let _ = run_test_tt_main tests
