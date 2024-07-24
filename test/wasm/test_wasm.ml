open Datastructures.Monad.DefBot

exception Empty

let p path = Interpreter.Analysis.analyze path
(*"./tc/fib.wasm"*)

let fib, _g =
  p
    "/home/ringzero/gitrepos/modular_chaotic_implicit_apron/test/wasm/tc/fib.wasm"

let _ = Fixpoint.Callgraph.CallGraph.print _g

let fr =
  fib >>=? fun x ->
  x

let sk_read (h : Memories.Operandstack.operand) =
  match h with
  | Expression e -> e
  | LVarRef _ -> failwith "lvref"
  | _ -> failwith "not expr not lvar @ ops"

let print o = Apronext.Texprext.print Format.std_formatter o
let ops = List.iter (fun x -> sk_read x |> print) fr.ops
