module AI = Apron.Interval
module AE = Apron.Environment
module AA1 = Apron.Abstract1

module ApronValue = struct
  type t = AI.t

  let of_scalar = AI.of_scalar
  let abs_compare = AI.cmp
  let compare = compare
end

module ApronEnvHelper = struct
  let make mgr = Apron.Abstract1.top mgr (Apron.Environment.make [||] [||])

  let add _mgr (_aenv : 'a AA1.t) alloc f =
    let _env = _aenv.env in
    let intarr, realarr = f alloc in
    let _env' = AE.add _env intarr realarr  in
    failwith ""
  (*let add = AE.add *)
  (* lookup *)
  (* meet (?) *)
  (* join *)
  (* widen *)
end
