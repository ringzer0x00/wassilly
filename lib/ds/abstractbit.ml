open Monad.DefBot

type abit = Zero | One | Top
type t = Def of abit | Bot

let zero = Def Zero
let one = Def One
let top = Def Top
let bot = Bot

let join (b1 : t) (b2 : t) =
  match (b1, b2) with
  | Bot, _ -> b2
  | _, Bot -> b1
  | Def d1, Def d2 -> (
      match (d1, d2) with
      | _, Top | Top, _ -> Def Top
      | Zero, One | One, Zero -> Def Top
      | Zero, Zero -> Def Zero
      | One, One -> Def One)

let widen = join

(** Inclusion between [Bit]s. *)

let eq b1 b2 = b1 = b2

let leq b1 b2 =
  match (b1, b2) with
  | Bot, _ -> true
  | _, Bot -> false
  | Def d1, Def d2 -> (
      match (d1, d2) with
      | Zero, Zero | One, One -> true
      | Zero, One | One, Zero -> false
      | Top, _ -> false
      | _, Top -> true)

let le b1 b2 = leq b1 b2 && not (eq b1 b2)

(** Logic AND between [Bit]s. *)
let l_and l r =
  l >>= fun l_def ->
  r >>= fun r_def ->
  let c =
    match (l_def, r_def) with
    | One, One -> One
    | _, Zero | Zero, _ -> Zero
    | _ -> Top
  in
  return c

(** Logic OR between [Bit]s. *)
let l_or l r =
  l >>= fun l_def ->
  r >>= fun r_def ->
  let c =
    match (l_def, r_def) with
    | Zero, Zero -> Zero
    | One, _ | _, One -> One
    | Top, Zero | Zero, Top | Top, Top -> Top
  in
  return c

(** Logic XOR between [Bit]s. *)
let l_xor l r =
  l >>= fun l_def ->
  r >>= fun r_def ->
  let c =
    match (l_def, r_def) with
    | Zero, Zero | One, One -> Zero
    | One, Zero | Zero, One -> One
    | Top, Zero | Zero, Top | One, Top | Top, One | Top, Top -> Top
  in
  return c

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
  | Def Zero -> Printf.printf "dZero"
  | Def One -> Printf.printf "dOne"
  | Def Top -> Printf.printf "dTop"
  | Bot -> Printf.printf "Bot"
