exception FailedInit

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

let analyze fn =
  let mod_ = load_mod fn in
  let startf, _ =
    match mod_.it.start with
    | None -> ([], [])
    | Some _st -> ( match Eval.getfbody mod_ 1 with a, b, _ -> (a, b))
  in
  let i = Init.init mod_ in
  let d' =
    match i with
    | Bot -> raise FailedInit
    | _ ->
        Eval.fixpoint mod_
          ((i, startf), true)
          Eval.Stack.empty Eval.Cache.empty Eval.MA.bot_pa Eval.step
  in
  d'
