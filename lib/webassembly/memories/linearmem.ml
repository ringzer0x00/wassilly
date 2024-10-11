module ABit = Datastructures.Abstractbit
module AByte = Datastructures.Abstractbyte

type bit = ABit.t
type byte = AByte.t
type page = byte array
type t = page (*page array really*)

(* a maximim number of pages is defined within the module *)

let wasm_page_size = 65536
let alloc_page n : page = Array.make (wasm_page_size * n) AByte.alloc_byte

let alloc_page_top n : page =
  Array.make (wasm_page_size * n) AByte.alloc_byte_top

let pageconcat (pold : t) (pnew : t) : t = Array.concat [ pold; pnew ]
let size m = Array.length m / wasm_page_size

let length_max m = Array.length m
let read_byte o (m : t) = Array.get m o

let internal_write_byte_raw b o (m : t) =
  let c = Array.copy m in
  (try Array.set c o b with Invalid_argument _ -> ());
  c

let internal_write_byte_weak b o m =
  let b' = AByte.join m.(o) b in
  internal_write_byte_raw b' o m

let strong_write_to_mem b o m =
  let mapped = Array.mapi (fun i x -> (x, i + o)) b in
  Array.fold_left
    (fun mem (byte, offs) -> internal_write_byte_raw byte offs mem)
    m mapped

let write_to_mem b o m =
  let mapped = Array.mapi (fun i x -> (x, i + o)) b in
  Array.fold_left
    (fun mem (byte, offs) -> internal_write_byte_weak byte offs mem)
    m mapped

let join (lm1 : t) (lm2 : t) : t =
  Array.map2 (fun fst snd -> AByte.join fst snd) lm1 lm2

let widen = join

let leq (lm1 : t) (lm2 : t) =
  Array.for_all2 (fun fst snd -> AByte.byte_leq fst snd) lm1 lm2

let eq (lm1 : t) (lm2 : t) =
  Array.for_all2 (fun fst snd -> AByte.byte_eq fst snd) lm1 lm2

let le (lm1 : t) (lm2 : t) = leq lm1 lm2 && not (eq lm1 lm2)
let read _ _ _ = failwith "read m-pos for n bytes"

let printmem (mem : t) =
  Array.iter
    (fun x ->
      AByte.print_byte x;
      Printf.printf "\n")
    mem
