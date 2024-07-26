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
