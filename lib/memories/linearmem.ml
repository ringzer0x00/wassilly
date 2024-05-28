module ABit = Datastructures.Abstractbit
module AByte = Datastructures.Abstractbyte

type bit = ABit.t
type byte = AByte.t
type page = byte array
type t = page (*page array really*)

(* a maximim number of pages is defined within the module *)

let wasm_page_size = 65536
let bits_in_byte = 8

(*default wasm memory value is 0, shout it be appropriate to make it Top though?*)
let alloc_page : page = Array.make wasm_page_size AByte.alloc_byte

(*(*(memory.grow (size expression))*)
  let pageconcat (pold : t) (pnew : t) : t = Array.concat [ pold; pnew ]
  let size m = Array.length m / wasm_page_size
*)
let join (lm1 : t) (lm2 : t) : t =
  Array.map2 (fun fst snd -> AByte.join fst snd) lm1 lm2

let widen = join

let leq (lm1 : t) (lm2 : t) =
  Array.for_all2 (fun fst snd -> AByte.byte_leq fst snd) lm1 lm2

let eq (lm1 : t) (lm2 : t) =
  Array.for_all2 (fun fst snd -> AByte.byte_eq fst snd) lm1 lm2

let le (lm1 : t) (lm2 : t) = leq lm1 lm2 && not (eq lm1 lm2)
