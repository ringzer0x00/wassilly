type bit = Zero | One | Bot | Top
type byte = bit array
type page = byte array
type t = page (*page array really*)

(* a maximim number of pages is defined within the module *)

let wasm_page_size = 65536
let bits_in_byte = 8

(*default wasm memory value is 0, shout it be appropriate to make it Top though?*)
let alloc_byte : byte = Array.make bits_in_byte Zero
let alloc_page : page = Array.make wasm_page_size alloc_byte
let join _ _ = failwith ""
let widen _ _ = failwith ""

let compare b1 b2 =
  (*compare x y returns 0 if x is equal to y, a negative integer if x is less than y, and a positive integer if x is greater than y.
      The ordering implemented by compare is compatible with the comparison predicates =, < and > defined above,
    with one difference on the treatment of the float value Stdlib.nan. Namely, the comparison predicates treat nan as different from any
    other float value, including itself; while compare treats nan as equal to itself and less than any other float value.
    This treatment of nan ensures that compare defines a total ordering relation.

      compare applied to functional values may raise Invalid_argument. compare applied to cyclic structures may not terminate.

      The compare function can be used as the comparison function required by the Set.Make and Map.Make functors, as well as the List.sort
       and Array.sort functions.*)
  (*partial order*)
  if b1 = b2 then 0
  else
    match (b1, b2) with
    | Top, _ | _, Bot -> 1
    | Bot, _ | _, Top -> -1
    | Zero, _ | One, _ -> 0

let joinBit b1 b2 =
  (*con compare viene piu pulito, per ora ok cosi*)
  match (b1, b2) with
  | Zero, One | One, Zero -> Top
  | Zero, Zero -> Zero
  | One, One -> One
  | Bot, (_ as r) | (_ as r), Bot -> r
  | Top, _ | _, Top -> Top

(*(memory.grow (size expression))*)
let pageconcat (pold : t) (pnew : t) : t = Array.concat [ pold; pnew ]
let size m = Array.length m / wasm_page_size

let leq _ _ = failwith ""
let eq _ _ = failwith ""
