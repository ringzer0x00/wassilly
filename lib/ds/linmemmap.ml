open Mapping
module Addr = Int32

let int_interval_of_interval a_ival =
  Apronext.Intervalext.to_mpqf a_ival
  |> Tuple.tuple_appl Mpqf.to_float
  |> Tuple.tuple_appl Int32.of_float

module LM = struct
  include Make (Addr) (Abstractbyte)

  let join lm1 lm2 =
    merge
      (fun _k x y ->
        match (x, y) with
        | None, None -> None
        | Some a, Some b -> Some (Abstractbyte.join a b)
        | Some a, None | None, Some a ->
            Some (Abstractbyte.join a Abstractbyte.alloc_byte))
      lm1 lm2

  let widen = join

  let internal_load a m =
    match find_opt a m with Some b -> b | None -> Abstractbyte.alloc_byte

  let internal_store a v m =
    update a
      (fun x ->
        match x with
        | None -> if v = Abstractbyte.alloc_byte then None else Some v
        | Some vold -> Some (Abstractbyte.join v vold))
      m

  let load (a_ival : Apronext.Intervalext.t) m =
    if Apronext.Intervalext.is_top a_ival then Abstractbyte.alloc_byte_top
    else if Apronext.Intervalext.is_bottom a_ival then failwith "bottom read"
    else
      let inf, sup = int_interval_of_interval a_ival in
      let r =
        List.init
          (Int32.sub sup inf |> Int32.to_int)
          (fun x -> Int32.add inf (Int32.of_int x))
      in
      let reads = List.map (fun x -> internal_load x m) r in
      List.fold_left
        (fun a x -> Abstractbyte.join a x)
        Abstractbyte.alloc_byte reads

  let store _a_ival _v _m = failwith ""
end
