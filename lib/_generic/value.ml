module type GVal = sig
  type t

  val top : t
  val bot : t
  val compare : t -> t -> int
  val leq : t -> t -> bool
  val lub : t -> t -> t
  val widen : t -> t -> t
end

module type GEx = sig
  type t
  type env

  val make : t
  val compare : t -> t -> int
  val concretize : t -> env -> int
  (*val lub : t -> t -> t
    val widen : t -> t -> t*)
end

module ApronValue : GVal = struct
  module AI = Apron.Interval
  module AS = Apron.Scalar

  type t = Apron.Interval.t

  let top = AI.top
  let bot = AI.bottom
  let pinf = AS.of_infty 1
  let ninf = AS.of_infty (-1)

  let max x y =
    let comp = AS.cmp x y >= 0 in
    match comp with true -> x | false -> y

  let min x y =
    let comp = AS.cmp x y >= 0 in
    match comp with true -> y | false -> x

  let lub (i1 : t) (i2 : t) =
    let r = AI.of_scalar (min i1.inf i2.inf) (max i1.sup i2.sup) in
    r

  let widen (smaller : t) (bigger : t) : t =
    match (AI.is_bottom smaller, AI.is_bottom bigger) with
    | true, true -> smaller
    | true, false -> bigger
    | false, true -> failwith "widen something with bottom"
    | false, false ->
        let (smaller_l, smaller_u), (bigger_l, bigger_u) =
          ((smaller.inf, smaller.sup), (bigger.inf, bigger.sup))
        in
        let lower' = if bigger_l < smaller_l then ninf else bigger_l in
        let upper' = if bigger_u > smaller_u then pinf else bigger_u in
        AI.of_scalar lower' upper'

  let compare = compare
  let leq i1 i2 = AI.is_leq i1 i2
end

module ApronExpr : GEx = struct
  module AEx = Apron.Texpr1

  type t = AEx.t
  type env

  let make = failwith ""
  let compare = compare
  let concretize _ _ = failwith ""
end
