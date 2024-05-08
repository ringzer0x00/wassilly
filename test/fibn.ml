open Chaotic_implicitgraph
open Command

let body =
  Language.If
    ( Language.Eq (Var "loc", Num 0),
      Num 0,
      Language.If
        ( Language.Eq (Var "loc", Num 1),
          Num 1,
          Language.Add
            ( Language.Call ("fib", [ Sub (Var "loc", Num 1) ]),
              Language.Call ("fib", [ Sub (Var "loc", Num 2) ]) ) ) )

let env =
  let e =
    Memory.Memory.add Eval.mgr "loc"
      (Value.makeval (Apron.Scalar.of_int 1) (Apron.Scalar.of_int 2))
      (Memory.Memory.make_empty Eval.mgr)
  in
  Apron.Abstract1.print Format.std_formatter e;
  e

let call = (env, Language.Call ("fib", [ Var "loc" ]))
let funs = Funcs.add "fib" ([ "loc" ], body) Funcs.empty
let output = Value.makeval (Apron.Scalar.of_int 0) Value.pinf

let v, _, _ =
  Eval.fixpoint funs (call, false) Stack.Stack.empty Cache.Cache.empty

let assertion = Apron.Interval.equal output v
