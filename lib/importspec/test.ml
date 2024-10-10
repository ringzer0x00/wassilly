open Main
open Term

let%test "IMPORTSPEC-empty_program" = parse_program "" = Program []

let%test "IMPORTSPEC-globs" =
  parse_program "glob x i32 [0;0]\nglob y i32 [0;0]"
  = Program
      [
        Glob ("x", I32Type, Num (I.of_int 0 0));
        Glob ("y", I32Type, Num (I.of_int 0 0));
      ]

let%test "IMPORTSPEC-table_unspec_spec" =
  parse_program "table x funcref [(1 -> 1);] unspec BOT"
  = Program
      [ Table ("x", Funcref, [ TableBinding (Int32.one, Int32.one) ], Bot) ]

let%test "IMPORTSPEC-table_unspec_unspec" =
  parse_program "table x funcref [(1 -> 1);]"
  = Program
      [ Table ("x", Funcref, [ TableBinding (Int32.one, Int32.one) ], Top) ]

let%test "IMPORTSPEC-table_binding_seq" =
  parse_program "table x funcref [(1 -> 1); (12 -> 2);]"
  = Program
      [
        Table
          ( "x",
            Funcref,
            [
              TableBinding (Int32.one, Int32.one);
              TableBinding (Int32.of_int 12, Int32.of_int 2);
            ],
            Top );
      ]

let%test "IMPORTSPEC-fib_loose" =
  parse_program "func fib ([param i32 x] -> [i32]) i32 [0;PINF] calls 0"
  = Program
      [
        Func
          ( "fib",
            FuncSig ([ Param (I32Type, "x") ], [ ResultType I32Type ]),
            Implies
              ( [
                  Result
                    ( I32Type,
                      Num (I.of_scalar (I.int_scalar 0) (I.inf_scalar 1)) );
                ],
                [],
                [ Calls (Int32.of_int 0) ] ) );
      ]

let%test "IMPORTSPEC-fib_precise" =
  parse_program
    "func fib ([param i32 x] -> [i32]) when x=0 => { i32 [0;0] } else { when \
     x=1 => { i32 [1;1] } else { i32 [1;PINF] calls 0 } }"
  = Program
      [
        Func
          ( "fib",
            FuncSig ([ Param (I32Type, "x") ], [ ResultType I32Type ]),
            Implication
              ( [ "x=0" ],
                ([ Result (I32Type, Num (I.of_int 0 0)) ], [], []),
                Implication
                  ( [ "x=1" ],
                    ([ Result (I32Type, Num (I.of_int 1 1)) ], [], []),
                    Implies
                      ( [
                          Result
                            ( I32Type,
                              Num
                                (I.of_scalar (I.int_scalar 1) (I.inf_scalar 1))
                            );
                        ],
                        [],
                        [ Calls (Int32.of_int 0) ] ) ) ) );
      ]

let%test "IMPORTSPEC-side" =
  parse_program "func mut ([] -> []) effect glob 0 i32 [1;1]"
  = Program
      [
        Func
          ( "mut",
            FuncSig ([], []),
            Implies
              ([], [ GlobAss (Int32.of_int 0, I32Type, Num (I.of_int 1 1)) ], [])
          );
      ]

let%test "IMPORTSPEC-postinst" =
  parse_program "postinst effect glob 0 i32 [1;1] effect glob 1 i32 [1;1]"
  = Program
      [
        PostInst
          [
            GlobAss (Int32.of_int 0, I32Type, Num (I.of_int 1 1));
            GlobAss (Int32.of_int 1, I32Type, Num (I.of_int 1 1));
          ];
      ]

let%test "importspec-rsa-test-mangled" =
  parse_program "func __wbg_new_693216e109162396 ([] -> [i32]) i32 [NINF;PINF]"
  = Program
      [
        Func
          ( "__wbg_new_693216e109162396",
            FuncSig ([], [ ResultType I32Type ]),
            Implies
              ( [
                  Result
                    ( I32Type,
                      Num (I.of_scalar (I.inf_scalar (-1)) (I.inf_scalar 1)) );
                ],
                [],
                [] ) );
      ]

let%test "importspec-rsa-test-id" =
  parse_program "func example ([] -> []) id"
  = Program [ Func ("example", FuncSig ([], []), Implies ([], [], [])) ]

let%test "func-sequence" =
  parse_program "func example1 ([] -> []) id\nfunc example2 ([] -> []) id\nfunc example3 ([] -> []) id"
  = Program
      [
        Func ("example1", FuncSig ([], []), Implies ([], [], []));
        Func ("example2", FuncSig ([], []), Implies ([], [], []));
        Func ("example3", FuncSig ([], []), Implies ([], [], []));

      ]
(*\n
  func __wbg_stack_0ddaca5d1abfb52f ([param i32 x param i32 y] -> []) id\n
  func __wbg_error_09919627ac0992f5 ([param i32 x param i32 y] -> []) id\n
  func __wbindgen_throw ([param i32 x param i32 y] -> []) id*)
