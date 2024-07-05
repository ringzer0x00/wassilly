open Segalang
open Command

let body : Language.t =
  [ Language.Loop (1, [ Language.Val 1l; Language.Br 0 ]) ]

let funs = Funcs.add "silly" ([], body) Funcs.empty
let mem = Memory.empty
let call = (Memory.empty, body)
let output = Apron.Interval.of_int 1 1
let pres : Eval.partial_result = { br = Labelmap.empty; return = Memory.Bot }

let result, _, _ =
  Eval.fixpoint funs (call, true) Stack.empty Cache.empty pres Eval.eval

let bind_result x _ =
  match x with Result.Bot -> true | Result.Def _ -> false

let ( >>= ) = bind_result

let assertion =
  result >>= fun _ -> false
