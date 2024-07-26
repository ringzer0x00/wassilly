module ABit = Datastructures.Abstractbit
module AByte = Datastructures.Abstractbyte

type bit = ABit.t
type byte = AByte.t
type page = byte array
type t = page (*page array really*)

(* a maximim number of pages is defined within the module *)

let wasm_page_size = 65536
let alloc_page : page = Array.make wasm_page_size AByte.alloc_byte
let alloc_page_top : page = Array.make wasm_page_size AByte.alloc_byte_top
let pageconcat (pold : t) (pnew : t) : t = Array.concat [ pold; pnew ]
let size m = Array.length m / wasm_page_size

let write_byte_raw b o (m : t) =
  m.(o) <- b;
  m

let write_byte_weak b o m =
  let b' = AByte.join m.(o) b in
  write_byte_raw b' o m

(*(*(memory.grow (size expression))*)
*)
let join (lm1 : t) (lm2 : t) : t =
  Array.map2 (fun fst snd -> AByte.join fst snd) lm1 lm2

let widen =
  Printf.printf "WARNING: LINEAR MEMORY IS NOT WIDENING\n";
  join

let leq (lm1 : t) (lm2 : t) =
  Array.for_all2 (fun fst snd -> AByte.byte_leq fst snd) lm1 lm2

let eq (lm1 : t) (lm2 : t) =
  Array.for_all2 (fun fst snd -> AByte.byte_eq fst snd) lm1 lm2

let le (lm1 : t) (lm2 : t) = leq lm1 lm2 && not (eq lm1 lm2)
let read _ _ _ = failwith "read m-pos for n bytes"
