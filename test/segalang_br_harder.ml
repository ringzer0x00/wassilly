open Segalang
open Command

let body : Language.t =
  [
    Language.Block
      (1, [ Language.Block (1, [ Language.Val 1l; Language.Br 1; Language.Val 666l; ]); Language.Val 666l; ]);
  ]

let funs = Funcs.add "silly" ([], body) Funcs.empty
let mem = Memory.empty
let call = (Memory.empty, body)
let output = Apron.Interval.of_int 1 1
let pres : Eval.partial_result = { br = Labelmap.empty; return = Memory.Bot }

let result, _, _ =
  Eval.fixpoint funs (call, true) Stack.empty Cache.empty pres Eval.eval

let bind_result x f =
  match x with Result.Bot -> failwith "BotRes" | Result.Def o -> f o

let ( >>= ) = bind_result

let bind_mem x f =
  match x with Memory.Bot -> failwith "BotMem" | Memory.Def o -> f o

let ( >>=^ ) = bind_mem

let assertion =
  result >>= fun d ->
  d.nat >>=^ fun m ->
  match m.opsk with
  | [] -> false
  | _h :: [] ->
      Apronext.Intervalext.print Format.std_formatter _h;
      Apronext.Intervalext.equal _h output
  | _h :: _ ->
      Apronext.Intervalext.print Format.std_formatter _h;
      false