let d = "/home/ringzero/gitrepos/wassilly/test/wasm/microbenchmarks/"

let p path =
  Interpreter.Analysis.value_and_callgraph
    (d ^ path ^ "/main.wasm")
    (d ^ path ^ "/spec.wassilly")

let got = Fixpoint.Callgraph.CallGraph.edges

let%test "MATTIA-fib-one-external" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  let m, g = p "MATTIA-fib-one-external" in
  let top_stack = Memories.Memorystate.peek_operand m |> List.hd in
  let val_conc = Memories.Memorystate.operand_as_interval top_stack m in
  let one_pinf =
    Apronext.Intervalext.of_scalar
      (Apronext.Scalarext.of_int 1)
      (Apronext.Scalarext.of_infty 1)
  in
  got g = [ (0, 0); (1, 0) ] && Apronext.Intervalext.cmp val_conc one_pinf = 0

let%test "MATTIA-abs-val-external" =
  Interpreter.Eval.cg := Fixpoint.Callgraph.CallGraph.phi;
  let m, g = p "MATTIA-abs-val-external" in
  let top_stack = Memories.Memorystate.peek_operand m |> List.hd in
  let val_conc = Memories.Memorystate.operand_as_interval top_stack m in
  let one_pinf =
    Apronext.Intervalext.of_scalar
      (Apronext.Scalarext.of_int 42)
      (Apronext.Scalarext.of_int 42)
  in
  got g = [ (1, 0) ] && Apronext.Intervalext.cmp val_conc one_pinf = 0
