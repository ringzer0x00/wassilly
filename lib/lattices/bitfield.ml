module BFLattice = struct
  type t = Zero | One | Top | Bot
  type env = unit
  type man = unit

  let mgr = ()
  let top _ = Top
  let bottom _ = Bot
  let isTop () = function Top -> true | _ -> false
  let isBottom () = function Bot -> true | _ -> false

  let lub b1 b2 =
    match (b1, b2) with
    | _, Top | Top, _ -> Top
    | Bot, (_ as a) | (_ as a), Bot -> a
    | Zero, One | One, Zero -> Top
    | Zero, Zero -> Zero
    | One, One -> One

  let widen = lub

  let meet b1 b2 =
    match (b1, b2) with
    | (_ as a), Top | Top, (_ as a) -> a
    | Bot, _ | _, Bot -> Bot
    | Zero, One | One, Zero -> Bot
    | Zero, Zero -> Zero
    | One, One -> One

  (** Inclusion between [Bit]s. *)

  let partialOrder b1 b2 =
    match (b1, b2) with
    | Zero, Zero | One, One -> true
    | Zero, One | One, Zero -> false
    | Top, _ -> false
    | _, Top -> true
    | Bot, _ -> false
    | _, Bot -> true

  let toString = function
    | Zero -> "Zero"
    | One -> "One"
    | Top -> "Top"
    | Bot -> "Bot"

  let print x = toString x |> print_string
end

(*
module Bitfield (L : Lattice.L) = struct
  include L

  let equals b1 b2 = b1 = b2
  let strictlySmaller b1 b2 = partialOrder b1 b2 && not (equals b1 b2)
end
*)
