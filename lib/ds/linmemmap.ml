open Mapping
module Addr = Int32

module LM = struct
  include Make (Addr) (Abstractbyte)

  let join _ = failwith ""
  let widen _ = failwith ""

  let internal_load a m =
    match find_opt a m with Some b -> b | None -> Abstractbyte.alloc_byte

  let load (a_ival : Apronext.Intervalext.t) m =
    if Apronext.Intervalext.is_top a_ival then Abstractbyte.alloc_byte_top
    else if Apronext.Intervalext.is_bottom a_ival then failwith "bottom read"
    else
      let inf, sup =
        Apronext.Intervalext.to_mpqf a_ival
        |> Tuple.tuple_appl Mpqf.to_float
        |> Tuple.tuple_appl Int32.of_float
      in
      let r =
        List.init
          (Int32.sub sup inf |> Int32.to_int)
          (fun x -> Int32.add inf (Int32.of_int x))
      in
      let reads = List.map (fun x -> internal_load x m) r in
      List.fold_left
        (fun a x -> Abstractbyte.join a x)
        Abstractbyte.alloc_byte reads
end
