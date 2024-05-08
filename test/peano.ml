open Chaotic_implicitgraph
open Command

let body =
  Language.If
    ( Language.Eq (Var "m", Num 1),
      Var "n",
      Language.Add
        (Language.Call ("peano", [ Sub (Var "m", Num 1); Var "n" ]), Num 1) )

let env =
  let e =
    Memory.Memory.add Eval.mgr "n"
      (Apron.Interval.of_int 1 1)
      (Memory.Memory.add Eval.mgr "m"
         (Apron.Interval.of_int 1 1)
         (Memory.Memory.make_empty Eval.mgr))
  in
  Apron.Abstract1.print Format.std_formatter e;
  e

let call = (env, Language.Call ("peano", [ Var "m"; Var "n" ]))
let funs = Funcs.add "peano" ([ "m"; "n" ], body) Funcs.empty
let output = Apron.Interval.of_scalar (Apron.Scalar.of_int 1) Value.pinf

let v, _, _ =
  Eval.fixpoint funs (call, false) Stack.Stack.empty Cache.Cache.empty

let assertion = Apron.Interval.equal output v
