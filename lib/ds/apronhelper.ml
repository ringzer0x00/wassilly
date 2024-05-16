module AI = Apron.Interval
module AEx = Apron.Texpr1
module AE = Apron.Environment
module AA1 = Apron.Abstract1

module type ApronValue = sig
  type t = AI.t

  val compare : t -> t -> int
  val lub : t -> t -> t
  val widen : t -> t -> t
  val leq : t -> t -> bool
end

module ApronValue : ApronValue = struct
  type t = AI.t

  let pinf = Apron.Scalar.of_infty 1
  let ninf = Apron.Scalar.of_infty (-1)

  let max x y =
    let comp = Apron.Scalar.cmp x y >= 0 in
    match comp with true -> x | false -> y

  let min x y =
    let comp = Apron.Scalar.cmp x y >= 0 in
    match comp with true -> y | false -> x

  let lub (i1 : t) (i2 : t) =
    let r = Apron.Interval.of_scalar (min i1.inf i2.inf) (max i1.sup i2.sup) in
    r

  let widen (smaller : t) (bigger : t) : t =
    match
      (Apron.Interval.is_bottom smaller, Apron.Interval.is_bottom bigger)
    with
    | true, true -> smaller
    | true, false -> bigger
    | false, true -> failwith "widen something with bottom"
    | false, false ->
        let (smaller_l, smaller_u), (bigger_l, bigger_u) =
          ((smaller.inf, smaller.sup), (bigger.inf, bigger.sup))
        in
        let lower' = if bigger_l < smaller_l then ninf else bigger_l in
        let upper' = if bigger_u > smaller_u then pinf else bigger_u in
        Apron.Interval.of_scalar lower' upper'

  let compare = compare
  let leq _ _ = failwith "todo"
end

module ApronExpression = struct
  type t = AEx.t

  let make = failwith ""
  let compare = compare
end

module ApronEnvHelper = struct
  let make mgr = Apron.Abstract1.top mgr (Apron.Environment.make [||] [||])

  let add _mgr (aenv : 'a AA1.t) alloc f =
    let env = aenv.env in
    let intarr, realarr, var = f alloc in
    let env' = AE.add env intarr realarr in
    let aenv = AA1.change_environment _mgr aenv env' false in
    (aenv, var)

  let assign _mgr _aenv _var _value = failwith ""
  let add_and_assign _ _ _ _ = failwith ""
  let lookup mgr env var : ApronValue.t = AA1.bound_variable mgr env var

  (*let add = AE.add *)
  (* lookup *)
  (* meet (?) *)
  (* join *)
  (* widen *)
end
