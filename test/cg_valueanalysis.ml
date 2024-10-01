let d = "/home/ringzero/gitrepos/wassilly/test/wasm/microbenchmarks/"

let p path =
  Interpreter.Analysis.value_and_callgraph
    (d ^ path ^ "/main.wasm")
    (d ^ path ^ "/spec.wassilly")
(*"./tc/fib.wasm"*)

let got = Fixpoint.Callgraph.CallGraph.edges

(*
let%test "MATTIA-direct-call-value" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  let m, g = p "MATTIA-direct-call-value" in
  let top_stack = Memories.Memorystate.peek_operand m |> List.hd in
  let val_conc = Memories.Memorystate.operand_as_interval top_stack m in
  got g = [ (1, 0) ]
  && Apronext.Intervalext.equal val_conc (Apronext.Intervalext.of_int 6 9)
*)
let%test "MATTIA-direct-call-mutated-global-val" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  let m, g = p "MATTIA-direct-call-mutated-global-val" in
  let top_stack = Memories.Memorystate.peek_operand m |> List.hd in
  let val_conc = Memories.Memorystate.operand_as_interval top_stack m in
  got g = [ (1, 0) ]
  && Apronext.Intervalext.equal val_conc (Apronext.Intervalext.of_int 7 7)


let%test "MATTIA-direct-call-mutated-global-ref" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  let m, g = p "MATTIA-direct-call-mutated-global-ref" in
  let top_stack = Memories.Memorystate.peek_operand m |> List.hd in
  let val_conc = Memories.Memorystate.operand_as_interval top_stack m in
  got g = [ (1, 0) ] && Apronext.Intervalext.equal val_conc (Apronext.Intervalext.of_int 14 14)


let t =
  [ (*imports*)
    (*("", [ (1, 0) ]);*)
    (*("host-callbacks-exports", []);*)
    (*("host-code-table-mutable", []);*)
    (*("host-reachable-table-export", []);*)
    (*("host-reachable-table-import", []);*)
    (*("table-init-offset-imported-global", []);*) ]
