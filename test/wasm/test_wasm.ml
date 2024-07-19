open Datastructures.Monad.DefBot

let p path = Interpreter.Analysis.analyze path
(*"./tc/fib.wasm"*)

let fib, _g =
  p
    "/home/ringzero/gitrepos/modular_chaotic_implicit_apron/test/wasm/tc/fib.wasm"

let _ = Fixpoint.Callgraph.CallGraph.print _g

let fr =
  fib >>=? fun x ->
  x.return >>=? fun ms -> ms

let ops =
  match List.hd fr.ops with
  | Expression e -> e
  | LVarRef _ -> failwith "lvref"
  | _ -> failwith "not expr not lvar @ ops"

let r = Apronext.Texprext.print Format.std_formatter ops
