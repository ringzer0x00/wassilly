module Bit = Datastructures.Abstractbit
module Byte = Datastructures.Abstractbyte

(* these should produce an expression containing an interval *)

let bitwise_and_or_eval arr =
  let inf =
    Array.fold_left
      (fun c x -> match x with Bit.One -> c + 1 | Bit.Zero | Bit.Top -> c)
      0 arr
  in
  let sup =
    Array.fold_left
      (fun c x -> match x with Bit.One | Bit.Top -> c + 1 | Bit.Zero -> c)
      0 arr
  in
  (inf, sup)

let l_xor l r = Array.map2 (fun x y -> Bit.l_xor x y) l r |> bitwise_and_or_eval
let l_and l r = Array.map2 (fun x y -> Bit.l_and x y) l r |> bitwise_and_or_eval
let l_or l r = Array.map2 (fun x y -> Bit.l_or x y) l r |> bitwise_and_or_eval

let clz _a =
  let to_both = Bit.filter_until _a Bit.Top |> Array.length in
  let to_one = Bit.filter_until _a Bit.One |> Array.length in
  if to_one >= to_both then (to_one, to_both) else (to_one, to_one)

let ctz _a =
  let _a_bits_reversed = Array.to_list _a |> List.rev |> Array.of_list in
  let to_both = Bit.filter_until _a_bits_reversed Bit.Top |> Array.length in
  let to_one = Bit.filter_until _a_bits_reversed Bit.One |> Array.length in
  if to_one >= to_both then (to_one, to_both) else (to_one, to_one)

let popcount ba =
  let min =
    Array.fold_left
      (fun c x -> match x with Bit.One -> c + 1 | Bit.Zero | Bit.Top -> c)
      0 ba
  in
  let max =
    Array.fold_left
      (fun c x -> match x with Bit.One | Bit.Top -> c + 1 | Bit.Zero -> c)
      0 ba
  in
  (min, max)
