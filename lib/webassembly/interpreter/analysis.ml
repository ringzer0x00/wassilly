exception FailedInit

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

let unbound_input _size (k : Memories.Frame.t) =
  match k with
  | Bot -> failwith "unbound input failure"
  | Def x ->
      Array.make _size
        (Memories.Operandstack.Expression
           (Memories.Operandstack.const_expr x.var Apronext.Intervalext.top))
      |> Array.to_list

let analyze fn =
  let mod_ = load_mod fn in
  let startf, _ =
    match mod_.it.start with
    | None -> ([], [])
    | Some _st -> ( match Eval.getfbody mod_ 1 with a, b, _ -> (a, b))
  in
  let _entrypoints =
    List.filter_map
      (fun (x : Wasm.Ast.export) ->
        match x.it.edesc.it with FuncExport v -> Some v | _ -> None)
      mod_.it.exports
  in
  let i = Init.init mod_ in
  let r_start, _, _ =
    match i with
    | Bot -> raise FailedInit
    | _ ->
        Eval.fixpoint mod_
          ((i, startf), true)
          Eval.Stack.empty Eval.Cache.empty Eval.MA.bot_pa Eval.step
  in
  let _b, _locs, _t =
    Eval.getfbody mod_ (Int32.to_int (List.hd _entrypoints).it)
  in
  let v_init =
    match r_start with
    | Bot -> raise FailedInit
    | Def d -> unbound_input 1 d.return
  in
  let l_start = Wasm.Ast.ValBlockType None in
  let l =
    Memories.Labelstack.block
      { natcont = []; brcont = []; typ = l_start; cmd = _b }
  in
  let call_ms =
    match r_start with
    | Bot -> raise FailedInit
    | Def d -> Cflow.prep_call d.return v_init mod_ _locs _t.it l
  in
  let ar, _, _ =
    Eval.fixpoint mod_
      ((call_ms, _b), true)
      Eval.Stack.empty Eval.Cache.empty Eval.MA.bot_pa Eval.step
  in
  ar
