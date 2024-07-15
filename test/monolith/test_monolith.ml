open OUnit2

let testify (tn, tf) = tn >:: tf

let all =
  "Monolith:" >::: List.map testify
    [
      ("fib", fun _ -> assert_equal true Fib.assertion);
      ("silly", fun _ -> assert_equal true Silly.assertion);
      ("fibdiv", fun _ -> assert_equal true Fibdiv.assertion);
      ("fibmix", fun _ -> assert_equal true Fibmix.assertion);
      ("fibn", fun _ -> assert_equal true Fibn.assertion);
      ("fact", fun _ -> assert_equal true Fact.assertion);
      ("peano", fun _ -> assert_equal true Peano.assertion);
    ] 
