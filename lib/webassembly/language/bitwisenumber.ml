open Utilities.Tuple
open Utilities.Conversions

let of_interval interval type_ =
  let val_ = Apronext.Intervalext.to_float interval in
  match type_ with
  | Wasm.Types.I32Type ->
      tuple_appl Int32.of_float val_
      |> tuple_appl s_int32_to_binary_array_twos_complement_msb
  | I64Type ->
      tuple_appl Int64.of_float val_
      |> tuple_appl s_int64_to_binary_array_twos_complement_msb
  | F32Type ->
      tuple_appl Int32.bits_of_float val_
      |> tuple_appl s_int32_to_binary_array_twos_complement_msb
  | F64Type ->
      tuple_appl Int64.bits_of_float val_
      |> tuple_appl s_int64_to_binary_array_twos_complement_msb

let split_in_bytes (a : int array) =
  let l = Array.length a / 8 in
  let _res = Array.make l (Array.make 8 0) in
  Array.iteri
    (fun i x ->
      let byte_pos = i / 8 in
      let pos_in_byte = i mod 8 in
      _res.(byte_pos).(pos_in_byte) <- x)
    a;
  _res

(*
let x =
  Language.Bitwisenumber.split_in_bytes
    [|
      1;
      2;
      3;
      4;
      5;
      6;
      7;
      8;
      1;
      2;
      3;
      4;
      5;
      6;
      7;
      8;
      1;
      2;
      3;
      4;
      5;
      6;
      7;
      8;
      1;
      2;
      3;
      4;
      5;
      6;
      7;
      8;
      1;
      2;
      3;
      4;
      5;
      6;
      7;
      8;
      1;
      2;
      3;
      4;
      5;
      6;
      7;
      8;
      1;
      2;
      3;
      4;
      5;
      6;
      7;
      8;
      1;
      2;
      3;
      4;
      5;
      6;
      7;
      8;
    |]

let () =
  Array.iter
    (fun x ->
      Printf.printf "[";
      Array.iter (fun x -> Printf.printf "%i; " x) x;
      Printf.printf "]\n")
    x;
  Printf.printf "%i" (Array.length x)
(*let _ = WASM.ops*)
*)
