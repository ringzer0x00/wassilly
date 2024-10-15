let d = "/home/ringzero/gitrepos/wassilly/test/wasm/tc/"
let p path = Interpreter.Analysis.value_and_callgraph (d ^ path ^ ".wasm") ""
let got = Datastructures.Callgraph.CallGraph.edges

let%test "largemem" =
  Interpreter.Eval.cg := Datastructures.Callgraph.CallGraph.phi;
  let m, _ = p "largemem" in
  let top_stack = Memories.Memorystate.peek_operand m |> List.hd in
  let val_conc = Memories.Memorystate.operand_as_interval top_stack m in
  Apronext.Intervalext.equal val_conc (Apronext.Intervalext.of_int 7 7)

let%test "and" =
  Interpreter.Eval.cg := Datastructures.Callgraph.CallGraph.phi;
  let m, _ = p "and" in
  let top_stack = Memories.Memorystate.peek_operand m |> List.hd in
  let val_conc = Memories.Memorystate.operand_as_interval top_stack m in
  Apronext.Intervalext.equal val_conc (Apronext.Intervalext.of_int 0 1)

let%test "br" =
  Interpreter.Eval.cg := Datastructures.Callgraph.CallGraph.phi;
  let m, _ = p "br" in
  let top_stack = Memories.Memorystate.peek_operand m |> List.hd in
  let val_conc = Memories.Memorystate.operand_as_interval top_stack m in
  Apronext.Intervalext.equal val_conc (Apronext.Intervalext.top)
