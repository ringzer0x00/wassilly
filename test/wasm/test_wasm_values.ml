open Datastructures.Monad.DefBot

exception Empty

let p path = Interpreter.Analysis.value_and_callgraph path
(*"./tc/fib.wasm"*)

let (fib, g), expected =
  ( p
      "/home/ringzero/gitrepos/wassilly/test/wasm/microbenchmarks/indirect-call-index-expr-memory-mutable/main.wasm",
    [ (0, 1) ] )

let _ = Fixpoint.Callgraph.CallGraph.print g
let e = Fixpoint.Callgraph.CallGraph.edges g
let () = assert (e = expected)
let fr = fib >>=? fun x -> x

let sk_read (h : Memories.Operand.operand) =
  match h with
  | Expression (e, _) -> e
  | LVarRef _ -> failwith "lvref"
  | _ -> failwith "not expr not lvar @ ops"

let print o = Apronext.Texprext.print Format.std_formatter o

let ops =
  List.iter
    (fun x ->
      Printf.printf "stack:";
      sk_read x |> print)
    fr.ops
