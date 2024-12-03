open Utilities.Tuple
open Utilities.Conversions
open Typing

type byte = {
  min : Datastructures.Abstractbyte.t;
  max : Datastructures.Abstractbyte.t;
}

type binary_interval = {
  min : Datastructures.Abstractbyte.t;
  max : Datastructures.Abstractbyte.t;
  t : num;
}

type abstract_byte = { val_ : Datastructures.Abstractbyte.t }
type abstract_bitwise = { val_ : Datastructures.Abstractbyte.t; t : num }

let byte_of_interval interval =
  let min, max =
    match Apronext.Intervalext.is_top interval with
    | true ->
        ( Array.make 8 Datastructures.Abstractbit.Zero,
          Array.make 8 Datastructures.Abstractbit.One )
    | false ->
        let _val_ = Apronext.Intervalext.to_float interval in
        tuple_appl Int32.of_float _val_
        |> tuple_appl s_int8_to_binary_array_twos_complement_msb
  in
  { min; max }

let of_interval interval (type_ : num) =
  let min, max =
    match not (Apronext.Intervalext.is_bounded interval) with
    | true -> (
        match type_ with
        | I32Type | F32Type ->
            ( Array.append
                (Array.make 1 Datastructures.Abstractbit.One)
                (Array.make 31 Datastructures.Abstractbit.Zero),
              Array.append
                (Array.make 1 Datastructures.Abstractbit.Zero)
                (Array.make 31 Datastructures.Abstractbit.One) )
        | I64Type | F64Type ->
            ( Array.append
                (Array.make 1 Datastructures.Abstractbit.One)
                (Array.make 63 Datastructures.Abstractbit.Zero),
              Array.append
                (Array.make 1 Datastructures.Abstractbit.Zero)
                (Array.make 63 Datastructures.Abstractbit.One) ))
    | false -> (
        let val_ = Apronext.Intervalext.to_float interval in
        match type_ with
        | I32Type ->
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
  let min, max, t = (bi.min, bi.max, bi.t) in
  { val_ = Datastructures.Abstractbyte.of_min_max min max; t }
