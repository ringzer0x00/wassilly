open Chaotic_implicitgraph
open Command

let body = Language.Mul (Var "loc0", Var "loc1")

let env =
  let e =
    Memory.Memory.add Eval.mgr "loc1"
      (Apron.Interval.of_int 2 2)
      (Memory.Memory.add Eval.mgr "loc0"
         (Apron.Interval.of_int 1 1)
         (Memory.Memory.make_empty Eval.mgr))
  in
  Apron.Abstract1.print Format.std_formatter e;
  e

let call = (env, Language.Call ("silly", [ Var "loc0"; Var "loc1" ]))
let funs = Funcs.add "silly" ([ "loc0"; "loc1" ], body) Funcs.empty
let output = Apron.Interval.of_int 2 2

let v, _, _ =
  Eval.fixpoint funs (call, false) Stack.Stack.empty Cache.Cache.empty

let assertion = Apron.Interval.equal output v
