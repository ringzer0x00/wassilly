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
  let i = Init.init (load_mod fn) in
  match i with
  | Bot -> raise FailedInit
  | Def d -> Apronext.Abstractext.print Format.std_formatter d.var.ad
