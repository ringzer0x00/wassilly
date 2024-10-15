type t = Zero | One | Top

(** Abstract operations between [Bit]s. *)

let join b1 b2 =
  match (b1, b2) with
  | _, Top | Top, _ -> Top
  | Zero, One | One, Zero -> Top
  | Zero, Zero -> Zero
  | One, One -> One

let widen = join

(** Inclusion between [Bit]s. *)

let eq b1 b2 = b1 = b2

let leq b1 b2 =
  match (b1, b2) with
  | Zero, Zero | One, One -> true
  | Zero, One | One, Zero -> false
  | Top, _ -> false
  | _, Top -> true

let le b1 b2 = leq b1 b2 && not (eq b1 b2)

(** Logic AND between [Bit]s. *)
let l_and l r =
  match (l, r) with
  | One, One -> One
  | _, Zero | Zero, _ -> Zero
  | _, Top | Top, _ -> Top

(** Logic OR between [Bit]s. *)
let l_or l r =
  match (l, r) with Zero, Zero -> Zero | One, _ | _, One -> One | _ -> Top

(** Logic XOR between [Bit]s. *)
let l_xor l r =
  match (l, r) with
  | Zero, Zero | One, One -> Zero
  | One, Zero | Zero, One -> One
  | _ -> Top

let filter_until arr filter =
  let l = Array.to_list arr in
  let rec apply_filter list acc =
    match list with
    | [] -> acc
    | h :: t -> if h = filter then acc else apply_filter t [ h ] @ acc
  in
  apply_filter l [] |> Array.of_list

(** [Bit]shifts **)

(** Print **)
let print = function
  | Zero -> Printf.printf "Zero"
  | One -> Printf.printf "One"
  | Top -> Printf.printf "Top"
