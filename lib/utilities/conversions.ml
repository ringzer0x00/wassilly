type numeric =
  | Float32 of float
  | Float64 of float
  | Integer32 of Int32.t
  | Integer64 of Int64.t

let s_int32_to_binary_array_twos_complement_msb (num : Int32.t) : int array =
  let size = 32 in
  let result = Array.make size 0 in

  let rec convert idx n =
    if idx < 0 then result
    else (
      result.(idx) <- Int32.to_int n land 1;
      convert (idx - 1) (Int32.shift_right_logical n 1))
  in

  let num' =
    if num < Int32.min_int then
      Int32.sub Int32.max_int (Int32.add (Int32.neg num) 1l)
    else num
  in

  convert (size - 1) num'

let s_int64_to_binary_array_twos_complement_msb (num : Int64.t) : int array =
  let size = 64 in
  let result = Array.make size 0 in

  let rec convert idx n =
    if idx < 0 then result
    else (
      result.(idx) <- Int64.to_int n land 1;
      convert (idx - 1) (Int64.shift_right_logical n 1))
  in

  let num' =
    if num < Int64.min_int then
      Int64.sub Int64.max_int (Int64.add (Int64.neg num) 1L)
    else num
  in

  convert (size - 1) num'

let int32_binary_to_decimal msb_to_lsb_binary_array =
  let rec aux acc power = function
    | [] -> acc
    | bit :: bits ->
        let value = Int32.mul (Int32.of_int bit) (Int32.shift_left 1l power) in
        aux (Int32.add acc value) (power - 1) bits
  in
  match msb_to_lsb_binary_array with
  | [] -> Int32.zero
  | 0 :: bits -> aux Int32.zero (List.length bits - 1) bits
  | 1 :: bits ->
      let inverted_bits = List.map (fun bit -> if bit = 0 then 1 else 0) bits in
      let decimal_value =
        Int32.sub Int32.zero
          (Int32.add
             (aux Int32.zero (List.length inverted_bits - 1) inverted_bits)
             Int32.one)
      in
      decimal_value
  | _ -> failwith "Invalid binary array"

let int64_binary_to_decimal msb_to_lsb_binary_array =
  let rec aux acc power = function
    | [] -> acc
    | bit :: bits ->
        let value = Int64.mul (Int64.of_int bit) (Int64.shift_left 1L power) in
        aux (Int64.add acc value) (power - 1) bits
  in
  match msb_to_lsb_binary_array with
  | [] -> Int64.zero
  | 0 :: bits -> aux Int64.zero (List.length bits - 1) bits
  | 1 :: bits ->
      let inverted_bits = List.map (fun bit -> if bit = 0 then 1 else 0) bits in
      let decimal_value =
        Int64.sub Int64.zero
          (Int64.add
             (aux Int64.zero (List.length inverted_bits - 1) inverted_bits)
             Int64.one)
      in
      decimal_value
  | _ -> failwith "Invalid binary array"

let int32_binary_to_decimal_wrapped arr =
  Integer32 (int32_binary_to_decimal arr)

let int64_binary_to_decimal_wrapped arr =
  Integer64 (int64_binary_to_decimal arr)

let float32_binary_to_decimal_wrapped arr =
  Float32 (int32_binary_to_decimal arr |> Int32.float_of_bits)

let float64_binary_to_decimal_wrapped arr =
  Float64 (int64_binary_to_decimal arr |> Int64.float_of_bits)

let float32_to_binary_array (num : float) : int array =
  Int32.bits_of_float num |> s_int32_to_binary_array_twos_complement_msb

let float64_to_binary_array (num : float) : int array =
  Int64.bits_of_float num |> s_int64_to_binary_array_twos_complement_msb
