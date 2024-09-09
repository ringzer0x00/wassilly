open Datastructures.Monad.DefBot

exception Empty

let p path = Interpreter.Analysis.analyze path
(*"./tc/fib.wasm"*)

let fib, _g =
  p
    "/home/ringzero/gitrepos/wassilly/test/wasm/microbenchmarks/table-init-offset-imported-global/main.wasm"

let _ = Fixpoint.Callgraph.CallGraph.print _g
let fr = fib >>=? fun x -> x

let sk_read (h : Memories.Operand.operand) =
  match h with
  | Expression (e, _) -> e
  | LVarRef _ -> failwith "lvref"
  | _ -> failwith "not expr not lvar @ ops"

let print o = Apronext.Texprext.print Format.std_formatter o
let ops = List.iter (fun x -> Printf.printf "stack:";sk_read x |> print) fr.ops
