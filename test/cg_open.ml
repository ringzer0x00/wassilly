let d = "/home/ringzero/gitrepos/wassilly/test/wasm/microbenchmarks/"

let p path =
  Interpreter.Analysis.callgraph_analysis'
    (d ^ path ^ "/main.wasm")
    (d ^ path ^ "/spec.wassilly")

let got = Datastructures.Callgraph.CallGraph.edges

let%test "memory-init-offset-imported-global" =
  Interpreter.Eval.cg := Datastructures.Callgraph.CallGraph.phi;
  got (p "memory-init-offset-imported-global") = [ (0, 1) ]

let%test "direct-call-imported-func" =
  Interpreter.Eval.cg := Datastructures.Callgraph.CallGraph.phi;
  got (p "direct-call-imported-func") = [ (1, 0) ]

let%test "table-init-offset-imported-global" =
  Interpreter.Eval.cg := Datastructures.Callgraph.CallGraph.phi;
  got (p "table-init-offset-imported-global") = [ (0, 1) ]

let%test "host-callbacks-exports" =
  Interpreter.Eval.cg := Datastructures.Callgraph.CallGraph.phi;
  got (p "host-callbacks-exports") = [ (0, 2); (1, 0); (2, 4); (3, 5) ]

let%test "host-reachable-table-export" =
  Interpreter.Eval.cg := Datastructures.Callgraph.CallGraph.phi;
  got (p "host-reachable-table-export") = [ (0, 2); (1, 0) ]

let%test "host-reachable-table-import" =
  Interpreter.Eval.cg := Datastructures.Callgraph.CallGraph.phi;
  got (p "host-reachable-table-import") = [ (0, 3); (1, 0) ]

let%test "MATTIA-host-code-table-mutable" =
  Interpreter.Eval.cg := Datastructures.Callgraph.CallGraph.phi;
  Datastructures.Callgraph.CallGraph.print (p "MATTIA-host-code-table-mutable");
  got (p "MATTIA-host-code-table-mutable") = [ (1, 0); (1, 3) ]

let%test "host-code-table-mutable" =
  Interpreter.Eval.cg := Datastructures.Callgraph.CallGraph.phi;
  got (p "host-code-table-mutable") = [ (0, 2) ]

let%test "MATTIA-indirect-call-index-expr-load-const-exported-memory-mutable" =
  Interpreter.Eval.cg := Datastructures.Callgraph.CallGraph.phi;
  got (p "MATTIA-indirect-call-index-expr-load-const-exported-memory-mutable")
  = [ (0, 1) ]
(*
let%test "cpp-vtable-layout-source-type-info" =
  Interpreter.Eval.cg := Datastructures.Callgraph.CallGraph.phi;
  let g = got (p "cpp-vtable-layout-source-type-info") in
  let g_lst =
    p "cpp-vtable-layout-source-type-info"
    |> Datastructures.Callgraph.CallGraph.to_list
  in
  let corr =
    [
      (0, "args_sizes_get");
      (1, "args_get");
      (2, "proc_exit");
      (3, "__wasm_call_ctors");
      (4, "module1_bool_");
      (5, "module2_bool_");
      (6, "main");
      (7, "A::method__");
      (8, "B::method__");
      (9, "C::method__");
      (10, "D::method__");
      (11, "_start");
      (12, "__original_main");
      (13, "__main_void");
      (14, "main.1");
      (15, "_Exit");
      (16, "libc_exit_fini");
      (17, "exit");
      (18, "_fini");
      (19, "stackSave");
      (20, "stackRestore");
      (21, "stackAlloc");
      (22, "__errno_location");
    ]
    |> List.map (fun (x, y) -> (Int32.of_int x, y))
  in
  let l' =
    List.map (fun (f, t) -> List.assoc f corr ^ "->" ^ List.assoc t corr) g_lst
  in
  List.iter (fun x -> Printf.printf "%s\n" x) l';
  g = []
*)