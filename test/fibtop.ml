open Monolith
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
      (Value.makeval Value.ninf Value.pinf)
      (Memory.Memory.make_empty Eval.mgr)
  in
  Apron.Abstract1.print Format.std_formatter e;
  e

let call = (env, Language.Call ("fib", [ Var "loc" ]))
let funs = Funcs.add "fib" ([ "loc" ], body) Funcs.empty
