open Segalang
open Command

let body : Language.t =
  [ Language.Block (1, [ Language.Val 1l; Language.Val 2l; Language.Mul ]) ]

let funs = Funcs.add "silly" ([], body) Funcs.empty
let mem = Memory.empty
let call = (Memory.empty, body)
let output = Apron.Interval.of_int 2 2
let pres : Eval.partial_result = { br = Labelmap.empty; return = Memory.Bot }

let _v, _, _ =
  Eval.fixpoint funs (call, true) Stack.empty Cache.empty pres Eval.eval

let assertion =
  let res =
    match _v with
    | Bot -> None
    | Def d -> (
        match d.nat with
        | Bot -> None
        | Memory.Def m -> (
            match m.opsk with
            | [] -> None
            | _h :: [] -> Some _h
            | _h :: _ -> None))
  in
  match res with None -> false | Some v -> v = output
