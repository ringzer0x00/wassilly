open Utilities.Tuple
open Utilities.Conversions

type byte = {
  min : Datastructures.Abstractbyte.t;
  max : Datastructures.Abstractbyte.t;
}

type binary_interval = {
  min : Datastructures.Abstractbyte.t;
  max : Datastructures.Abstractbyte.t;
  t : Wasm.Types.num_type;
}

type abstract_byte = {val_ : Datastructures.Abstractbyte.t}

type abstract_bitwise = {
  val_ : Datastructures.Abstractbyte.t;
  t : Wasm.Types.num_type;
}

let byte_of_interval interval =
  let min, max =
    match Apronext.Intervalext.is_top interval with
    | true ->
        ( Array.make 8 Datastructures.Abstractbit.Zero,
          Array.make 8 Datastructures.Abstractbit.One )
    | false ->
        let _val_ = Apronext.Intervalext.to_float interval in
        tuple_appl Int32.of_float _val_
        |> tuple_appl s_int32_to_binary_array_twos_complement_msb
  in
  { min; max }

let of_interval interval type_ =
  let min, max =
    match Apronext.Intervalext.is_top interval with
    | true -> (
        match type_ with
        | Wasm.Types.I32Type | F32Type ->
            ( Array.make 32 Datastructures.Abstractbit.Zero,
              Array.make 32 Datastructures.Abstractbit.One )
        | I64Type | F64Type ->
            ( Array.make 64 Datastructures.Abstractbit.Zero,
              Array.make 64 Datastructures.Abstractbit.One ))
    | false -> (
        let val_ = Apronext.Intervalext.to_float interval in
        Printf.printf "val_: %f" (fst val_);
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
            |> tuple_appl s_int64_to_binary_array_twos_complement_msb)
  in
  { min; max; t = type_ }

let binary_interval_to_abstract_bitwise bi =
  let _min, _max, _t = (bi.min, bi.max, bi.t) in
  failwith "SBAGLIATO: { val_ = Datastructures.Abstractbyte.join min max; t }"

(*needed to facilitate writing in memory.*)
let split_in_bytesized_arrays a =
  let l = Array.length a / 8 in
  let _res = Array.make l (Array.make 8 a.(0)) in
  Array.iteri
    (fun i x ->
      let byte_pos = i / 8 in
      let pos_in_byte = i mod 8 in
      _res.(byte_pos).(pos_in_byte) <- x)
    a;
  _res
