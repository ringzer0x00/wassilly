module ABit = Datastructures.Abstractbit
module AByte = Datastructures.Abstractbyte
module LinMem = Datastructures.Linmemmap.LimitedLinearMemory

type t = M of LinMem.t | T of { min : int32; max : int32 }
(*page array really*)

let printer = Utilities.Printer.print
(* a maximim number of pages is defined within the module *)

let wasm_page_size = 65536l

let alloc_page n =
  M (LinMem.mk_empty (Int32.mul wasm_page_size (Int32.of_int n)))

let top n = T { min = 0l; max = n }

let size = function
  | M m -> Int32.div m.max wasm_page_size
  | T m -> Int32.div m.max wasm_page_size

let length_max = function M m -> m.max | T m -> m.max

let read_byte o = function
  | M m -> LinMem.load o m
  | T _ -> Some AByte.alloc_byte_top

let internal_write_byte_raw b o =
  printer Format.print_string "\t ~ RAW MEMWRITE (INIT) in: ";
  printer Format.print_string (Int32.to_string o);
  printer Format.print_newline ();
  function
  | M m -> (
      match LinMem.store o b m with
      | Some m -> M m
      | None -> failwith "oob raw write")
  | T m -> T m

let internal_write_byte_weak b o m =
  match LinMem.store o b m with
  | Some m -> m
  | None -> failwith "oob write @ linearmem"

let strong_write_to_mem b o m =
  let mapped = Array.mapi (fun i x -> (x, Int32.add (Int32.of_int i) o)) b in
  printer Format.print_string "strongwrite!";
  Array.fold_left
    (fun mem (byte, offs) -> internal_write_byte_raw byte offs mem)
    m mapped

let write_to_mem b o m =
  match m with
  | M m ->
      let mapped =
        Array.mapi (fun i x -> (x, Int32.add (Int32.of_int i) o)) b
      in
      M
        (Array.fold_left
           (fun mem (byte, offs) -> internal_write_byte_weak byte offs mem)
           m mapped)
  | T _ -> m

let join m1 m2 =
  match (m1, m2) with
  | _, T t | T t, _ -> T t
  | M m1, M m2 -> M (LinMem.join m1 m2)

let widen = join

let leq m1 m2 =
  match (m1, m2) with
  | T _, T _ -> true
  | M _, T _ -> true
  | T _, M _ -> false
  | M m1, M m2 -> LinMem.leq m1 m2

let eq m1 m2 =
  match (m1, m2) with
  | T _, T _ -> true
  | M _, T _ | T _, M _ -> false
  | M m1, M m2 -> LinMem.eq m1 m2

let le = LinMem.le
let read _ _ _ = failwith "read m-pos for n bytes"

let printmem (mem : t) =
  (*Array.iter
    (fun x ->
      AByte.print_byte x;
      Format.printf "\n")
  *)
  ignore mem
