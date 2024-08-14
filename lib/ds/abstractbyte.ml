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

let of_min_max _mi _ma =
  let a =
    Array.map2 (fun a b -> Abstractbit.join a b) _mi _ma |> Array.to_list
  in
  (*once you find Both, from that Both *all* is Both*)
  let rec meaow arr acc =
    Printf.printf "MEAOW CALLED\n\n\n\n";
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
        meaow t' (acc @ [ x' ] @ r)
  in
  meaow a []
