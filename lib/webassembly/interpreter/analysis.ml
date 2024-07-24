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

let unbound_input t_in (k : Memories.Frame.t) =
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
(*Array.make _size
    (Memories.Operand.Expression
       (Memories.Operand.const_expr x.var Apronext.Intervalext.top))
  |> Array.to_list*)

let analyze fn =
  let mod_ = load_mod fn in
  let startf, _, fstart =
    match mod_.it.start with
    | None -> ([], [], Int32.minus_one)
    | Some _st -> (
        match Eval.getfbody mod_ 1 with a, b, _ -> (a, b, Int32.minus_one))
  in
  let _entrypoints =
    List.filter_map
      (fun (x : Wasm.Ast.export) ->
        match x.it.edesc.it with FuncExport v -> Some v | _ -> None)
      mod_.it.exports
  in
  let i = Init.init mod_ in
  let r_start, _, _ =
    i >>=? fun _ ->
    Eval.fixpoint mod_
      ((i, startf), true)
      Eval.Stack.empty Eval.Cache.empty fstart ([], []) Eval.MA.bot_pa Eval.step
  in
  let _b, _locs, _t =
    Eval.getfbody mod_ (Int32.to_int (List.hd _entrypoints).it)
  in
  let t_in, _t_out =
    match Eval.gettype mod_ (Int32.to_int _t.it) with FuncType (i, o) -> (i, o)
  in
  let call_ms =
    r_start >>=? fun d ->
    Cflow.prep_call d.return (unbound_input t_in d.return) mod_ _locs _t.it _t
  in
  let ar, _, _ =
    Eval.fixpoint mod_
      ((call_ms, _b), true)
      Eval.Stack.empty Eval.Cache.empty (List.hd _entrypoints).it (t_in, _t_out)
      Eval.MA.bot_pa Eval.step
  in
  let ar = Eval.MS.func_res (Eval.func_ans ar) call_ms (List.length _t_out) in
  (ar, !Eval.cg)
