open Datastructures.Monad.DefBot

let load name bs = Wasm.Decode.decode name bs

let read_whole_file filename =
  (* open_in_bin works correctly on Unix and Windows *)
  let ch = open_in_bin filename in
  let s = really_input_string ch (in_channel_length ch) in
  close_in ch;
  s

let load_mod fn =
  let bytes = read_whole_file fn in
  load fn bytes

let parse_spec fn =
  match fn with
  | "" -> Importspec.Term.Program []
  | _ ->
      let bytes = read_whole_file fn in
      Importspec.Main.parse_program bytes

let unbound_input t_in (k : Memories.Memorystate.t) =
  k >>=? fun x ->
  let _size = List.length t_in in
  List.map
    (fun t ->
      let t' =
        match t with
        | Wasm.Types.NumType t' -> t'
        | _ -> failwith "failure, not numtype as input"
      in
      Memories.Operand.Expression
        (Memories.Operand.const_expr x.var Apronext.Intervalext.top, t'))
    t_in

let value_and_callgraph fn _spec_path =
  let mod_ = load_mod fn in
  let spec = parse_spec _spec_path in
  let i, minst = Init.init mod_ spec in
  let startf, _, fstart =
    match mod_.it.start with
    | None -> ([], [], Int32.minus_one)
    | Some _st -> (
        match Eval.getfbody minst (Int32.to_int _st.it.sfunc.it) with
        | a, _, _ -> (a, [], _st.it.sfunc.it))
  in
  let entrypoints =
    List.filter_map
      (fun (x : Wasm.Ast.export) ->
        match x.it.edesc.it with FuncExport v -> Some v | _ -> None)
      mod_.it.exports
  in
  let _fs_all = List.mapi (fun i _ -> Int32.of_int i) mod_.it.funcs in
  let r_start, _, _ =
    i >>=? fun _ ->
    Eval.fixpoint minst
      ((i, startf), true)
      Eval.Stack.empty Eval.Cache.empty fstart ([], []) Eval.MA.bot_pa Eval.step
  in

  match entrypoints with
  | [] -> (Eval.MS.func_res (Eval.func_ans r_start) i 0, !Eval.cg)
  | _ ->
      let _b, _locs, _t =
        Eval.getfbody minst (Int32.to_int (List.hd entrypoints).it)
      in
      let t_in, _t_out =
        match Eval.gettype minst (Int32.to_int _t.it) with
        | FuncType (i, o) -> (i, o)
      in
      let call_ms =
        r_start >>=? fun d ->
        Cflow.prep_call d.return (unbound_input t_in d.return) minst _locs _t.it
      in
      let ar, _, _ =
        Eval.fixpoint minst
          ((call_ms, _b), true)
          Eval.Stack.empty Eval.Cache.empty (List.hd entrypoints).it
          (t_in, _t_out) Eval.MA.bot_pa Eval.step
      in
      (*
      let ar =
        Eval.MS.func_res (Eval.func_ans ar) call_ms (List.length _t_out)
      in*)
      (Eval.func_ans ar, !Eval.cg)

let callgraph_analysis' fn _spec_path =
  let mod_ = load_mod fn in
  let spec = parse_spec _spec_path in
  let i, minst = Init.init mod_ spec in
  let startf, _, fstart =
    match mod_.it.start with
    | None -> ([], [], Int32.minus_one)
    | Some _st -> (
        match Eval.getfbody minst (Int32.to_int _st.it.sfunc.it) with
        | a, _, _ -> (a, [], _st.it.sfunc.it))
  in
  let entrypoints =
    List.filter_map
      (fun (x : Wasm.Ast.export) ->
        match x.it.edesc.it with FuncExport v -> Some v | _ -> None)
      mod_.it.exports
  in
  let _fs_all = List.mapi (fun i _ -> Int32.of_int i) mod_.it.funcs in
  let r_start, c, _ =
    i >>=? fun _ ->
    Eval.fixpoint minst
      ((i, startf), true)
      Eval.Stack.empty Eval.Cache.empty fstart ([], []) Eval.MA.bot_pa Eval.step
  in
  List.fold_left
    (fun (cg, cache) (y : Wasm.Ast.var) ->
      Eval.cg := Datastructures.Callgraph.CallGraph.phi;
      let fb, locs, ft = Eval.getfbody minst (Int32.to_int y.it) in
      let t_in, _t_out =
        match Eval.gettype minst (Int32.to_int ft.it) with
        | FuncType (i, o) -> (i, o)
      in
      let call_ms =
        r_start >>=? fun d ->
        Cflow.prep_call d.return (unbound_input t_in d.return) minst locs ft.it
      in
      let _, cache', _ =
        Eval.fixpoint minst
          ((call_ms, fb), true)
          Eval.Stack.empty cache y.it (t_in, _t_out) Eval.MA.bot_pa Eval.step
      in
      (Datastructures.Callgraph.CallGraph.union cg !Eval.cg, cache'))
    (!Eval.cg, c) entrypoints
  |> fst
