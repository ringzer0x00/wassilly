type bit = Zero | One | Bot | Top
type byte = bit array
type page = byte array
type t = page

let wasm_page_size = 65536
let bits_in_byte = 8

(*default wasm memory value is 0, shout it be appropriate to make it Top though?*)
let alloc_byte : byte = Array.make bits_in_byte Zero
let alloc_page : page = Array.make wasm_page_size alloc_byte
let compare _ _ = failwith "definire"

let joinBit b1 b2 =
  (*con compare viene piu pulito, per ora ok cosi*)
  match (b1, b2) with
  | Zero, One | One, Zero -> Top
  | Zero, Zero -> Zero
  | One, One -> One
  | Bot, (_ as r) | (_ as r), Bot -> r
  | Top, _ | _, Top -> Top
