open OUnit2

let testify (tn, tf) = tn >:: tf

let all =
  "Monolith:"
  >::: List.map testify
         [
           ( "segalang_silly",
             fun _ -> assert_equal true Silly_segalang.assertion );
           ("segalang_if", fun _ -> assert_equal true If_segalang.assertion);
           ("segalang_br", fun _ -> assert_equal true Segalang_br.assertion);
           ( "segalang_br_harder",
             fun _ -> assert_equal true Segalang_br_harder.assertion );
           ( "segalang_br_loop",
             fun _ -> assert_equal true Segalang_br_loop.assertion );
           ( "segalang_brif_loop",
             fun _ -> assert_equal true Segalang_brif_loop.assertion );
           ( "segalang_loop_if",
             fun _ -> assert_equal true Segalang_loop_if.assertion );
         ]