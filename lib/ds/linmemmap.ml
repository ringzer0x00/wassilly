open Mapping
module Addr = Int32

let int_interval_of_interval a_ival =
  Apronext.Intervalext.to_mpqf a_ival
  |> Tuple.tuple_appl Mpqf.to_float
  |> Tuple.tuple_appl Int32.of_float

module LinearMemory = struct
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
  let order lm1 lm2 = compare (fun a b -> Abstractbyte.total_order a b) lm1 lm2
  let eq lm1 lm2 = if order lm1 lm2 = 0 then true else false

  let leq lm1 lm2 =
    if order lm1 lm2 = 0 || order lm1 lm2 = -1 then true else false

  let le lm1 lm2 = if order lm1 lm2 = -1 then true else false

  let internal_load a m =
    match find_opt a m with Some b -> b | None -> Abstractbyte.alloc_byte

  let internal_store a v m =
    update a
      (fun x ->
        match x with
        | None -> if v = Abstractbyte.alloc_byte then None else Some v
        | Some vold -> Some (Abstractbyte.join v vold))
      m
  (*
  let load a_ival m =
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

  let store (a) (_v : Apronext.Intervalext.t) _m =
    failwith ""*)
end

module LimitedLinearMemory = struct
  type t = { m : LinearMemory.t; min : int32; max : int32 }

  let mk_empty max = { m = LinearMemory.empty; min = Int32.zero; max }

  let ho_memo f m1 m2 =
    if m1.min = m2.min && m1.max = m2.max then f m1 m2
    else failwith "cannot perform operation hh_memo"

  let join m1 m2 =
    ho_memo
      (fun m1 m2 ->
        { m = LinearMemory.join m1.m m2.m; min = m1.min; max = m1.max })
      m1 m2

  let widen = join
  let le m1 m2 = ho_memo (fun m1 m2 -> LinearMemory.le m1.m m2.m) m1 m2
  let leq m1 m2 = ho_memo (fun m1 m2 -> LinearMemory.leq m1.m m2.m) m1 m2
  let eq m1 m2 = ho_memo (fun m1 m2 -> LinearMemory.eq m1.m m2.m) m1 m2

  let load a m =
    if a >= m.min && a <= m.max then Some (LinearMemory.internal_load a m.m)
    else None

  let store a v m =
    if a >= m.min && a <= m.max then Some (LinearMemory.internal_store a v m.m)
    else None
end
