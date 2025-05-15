let%test "minus_sixteen" =
  let b =
    Language.Bitwisenumber.of_interval
      (Apronext.Intervalext.of_int (-16) (-16))
      Wasm.Types.I32Type
  in
  b.min = b.max
  && b.min
     = Data_test.min_siexteen
