module ABit = Datastructures.Abstractbit
module AByte = Datastructures.Abstractbyte
module LinMem = Datastructures.Linmemmap.LimitedLinearMemory

type t = LinMem.t (*page array really*)

let printer = Utilities.Printer.print
(* a maximim number of pages is defined within the module *)

let wasm_page_size = 65536l
let alloc_page n = LinMem.mk_empty (Int32.mul wasm_page_size (Int32.of_int n))
let size (m : t) = Int32.div m.max wasm_page_size
let length_max (m : t) = m.max
let read_byte o (m : t) = LinMem.load o m

let internal_write_byte_raw b o m =
  printer Format.print_string "\t ~ RAW MEMWRITRE (INIT) in: ";
  printer Format.print_string (Int32.to_string o);
  printer Format.print_newline ();
  match LinMem.store o b m with Some m -> m | None -> failwith "oob raw write"

let internal_write_byte_weak b o m =
  match LinMem.store o b m with
  | Some m -> m
  | None -> failwith "oob write @ linearmem"

let strong_write_to_mem b o m =
  let mapped = Array.mapi (fun i x -> (x, Int32.add (Int32.of_int i) o)) b in
  Array.fold_left
    (fun mem (byte, offs) ->
     internal_write_byte_raw byte offs mem)
    m mapped

let write_to_mem b o m =
  let mapped = Array.mapi (fun i x -> (x, Int32.add (Int32.of_int i) o)) b in
  Array.fold_left
    (fun mem (byte, offs) -> internal_write_byte_weak byte offs mem)
    m mapped

let join = LinMem.join
let widen = join
let leq = LinMem.leq
let eq = LinMem.eq
let le = LinMem.le
let read _ _ _ = failwith "read m-pos for n bytes"

let printmem (mem : t) =
  (*Array.iter
    (fun x ->
      AByte.print_byte x;
      Format.printf "\n")
  *)
  ignore mem
