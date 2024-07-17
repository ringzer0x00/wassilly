open Datastructures.Monad.DefBot

let destroy_monad = function Bot -> failwith "bot @ destroymonad" | Def d -> d
let p path = Interpreter.Analysis.analyze path
(*"./tc/fib.wasm"*)

let fib = p "/home/ringzero/gitrepos/modular_chaotic_implicit_apron/test/wasm/tc/table_nullref.wasm"

let fr =
  match (destroy_monad fib).return with
  | Bot -> failwith "bot @ result"
  | Def ms -> ms

let ops =
  match List.hd fr.ops with
  | Expression e -> e
  | LVarRef _ -> failwith "lvref"
  | _ -> failwith "not expr not lvar @ ops"

let length = List.length fr.ops
let r = Apronext.Texprext.print Format.std_formatter ops
