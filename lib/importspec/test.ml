open Main
open Term

let%test "empty_program" = parse_program "" = Program []

let%test "globs" =
  parse_program "glob x i32 [0;0]\nglob y i32 [0;0]"
  = Program
      [
        Glob ("x", I32Type, Num (I.of_int 0 0));
        Glob ("y", I32Type, Num (I.of_int 0 0));
      ]

let%test "table_unspec_spec" =
  parse_program "table x funcref [(1 -> 1);] unspec BOT"
  = Program
      [ Table ("x", Funcref, [ TableBinding (Int32.one, Int32.one) ], Bot) ]

(*  | Table of string * tabType * tableBinding list * unspec
*)
let%test "table_unspec_unspec" =
  parse_program "table x funcref [(1 -> 1);]"
  = Program
      [ Table ("x", Funcref, [ TableBinding (Int32.one, Int32.one) ], Top) ]

let%test "table_binding_seq" =
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

let%test "fib_loose" =
  parse_program "func fib ([param i32 x] -> [i32]) i32 [0;PINF] calls fib"
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
                [ Calls "fib" ] ) );
      ]

let%test "fib_precise" =
  parse_program
    "func fib ([param i32 x] -> [i32]) when x=0 => { i32 [0;0] } else { when \
     x=1 => { i32 [1;1] } else { i32 [1;PINF] calls fib } }"
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
                        [ Calls "fib" ] ) ) ) );
      ]

let%test "side" =
  parse_program "func mut ([] -> []) effect glob x i32 [1;1]"
  = Program
      [
        Func
          ( "mut",
            FuncSig ([], []),
            Implies ([], [ GlobAss ("x", I32Type, Num (I.of_int 1 1)) ], []) );
      ]