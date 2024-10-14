type t = Abstractbit.t array

let def_init = Abstractbit.Zero
let def_init_top = Abstractbit.Top

(** Abstract [Byte] allocation, set to [Zero]. *)
let alloc_byte : t = Array.make 8 def_init

(** Abstract [Byte] allocation, set to [Top]. *)
let alloc_byte_top : t = Array.make 8 def_init_top

(** Abstract operations between [Byte]s. *)
let join b1 b2 = Array.map2 (fun fst snd -> Abstractbit.join fst snd) b1 b2

let widen = join

(** Inclusion operations between [Byte]s. *)
let byte_leq b1 b2 =
  Array.for_all2 (fun fst snd -> Abstractbit.leq fst snd) b1 b2

let byte_eq b1 b2 = Array.for_all2 (fun fst snd -> Abstractbit.eq fst snd) b1 b2

let byte_le b1 b2 =
  Array.for_all2
    (fun fst snd -> Abstractbit.leq fst snd && not (Abstractbit.eq fst snd))
    b1 b2

(* creation *)
let of_int_array a =
  Array.map
    (fun x ->
      match x with
      | 0 -> Abstractbit.Zero
      | 1 -> Abstractbit.One
      | _ -> failwith "cannot create array from int")
    a

let to_int_array =
  Array.map (fun x ->
      match x with
      | Abstractbit.Zero -> 0
      | Abstractbit.One -> 1
      | _ -> failwith "cannot doooo")

let to_int_array_minmax =
  Array.map (fun x ->
      match x with
      | Abstractbit.Zero -> (0, 0)
      | Abstractbit.One -> (1, 1)
      | Abstractbit.Top -> (0, 1))

let of_min_max _mi _ma =
  let a =
    Array.map2 (fun a b -> Abstractbit.join a b) _mi _ma |> Array.to_list
  in
  (*once you find Both, from that Both *all* is Both*)
  let rec collapse arr acc =
    match arr with
    | [] -> Array.of_list acc
    | h :: t ->
        let x', t', r =
          match h with
          | Abstractbit.Top ->
              ( Abstractbit.Top,
                [],
                Array.to_list (Array.make (List.length t) Abstractbit.Top) )
          | _ as rest -> (rest, t, [])
        in
        collapse t' (acc @ [ x' ] @ r)
  in
  collapse a []

let as_min_max a signed =
  let minmax_pos x =
    match x with
    | Abstractbit.Top -> (Abstractbit.Zero, Abstractbit.One)
    | _ as d -> (d, d)
  in
  let minmax_neg x =
    match x with
    | Abstractbit.Top -> (Abstractbit.One, Abstractbit.Zero)
    | _ as d -> (d, d)
  in
  let minmax_negpos a =
    (Abstractbit.One, Abstractbit.Zero)
    :: List.map
         (fun x ->
           match x with
           | Abstractbit.Top -> (Abstractbit.Zero, Abstractbit.One)
           | _ as d -> (d, d))
         a
  in
  (*BUG(29 aug-2024): this is not correct, as the interpretation of these numbers, when all is top, is -1;0*)
  let minmax =
    match signed with
    | false -> Array.map minmax_pos a
    | true -> (
        let aslist = Array.to_list a in
        let s, v = (List.hd aslist, List.tl aslist) in
        match s with
        | Abstractbit.Zero -> Array.map minmax_pos a
        | One -> Array.map minmax_neg a
        | Top -> minmax_negpos v |> Array.of_list)
  in
  Array.split minmax

(*needed to facilitate writing in memory.*)
let split_in_bytesized_arrays a =
  let sub x a = Array.sub a x 8 in
  let l = Array.length a / 8 in
  let acc = Array.make l (Array.make 8 Abstractbit.Zero) in
  for iter = 0 to l - 1 do
    let s = sub (iter * 8) a in
    acc.(iter) <- s
  done;
  acc

let as_int_arrays ?(signed = false) a =
  let min, max = as_min_max a signed in
  (to_int_array min, to_int_array max)

let print_byte b = Array.iter (fun x -> Abstractbit.print x) b
