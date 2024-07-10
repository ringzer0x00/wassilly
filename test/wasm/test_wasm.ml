open Datastructures.Monad

let destroy_monad = function Bot -> failwith "bot @ destroymonad" | Def d -> d
let p path = Interpreter.Analysis.analyze path
(*"./tc/fib.wasm"*)

let fib, _, _ = p "./tc/fibif.wasm"

let fr =
  match (destroy_monad fib).return with
  | Memories.Frame.Bot -> failwith "bot @ result"
  | Def ms -> ms

let ops = match List.hd fr.ops with Expression e -> e | _ -> failwith "bot @ ops"
let r = Apronext.Texprext.print Format.std_formatter ops
