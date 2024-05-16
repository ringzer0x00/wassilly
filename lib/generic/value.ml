module type GVal = sig
  type t

  val compare : t -> t -> int
  val leq : t -> t -> bool
  val lub : t -> t -> t
  val widen : t -> t -> t
end

module type GEx = sig
  type t

  val compare : t -> t -> int
  (*val lub : t -> t -> t
    val widen : t -> t -> t*)
end

module ApronValue : GVal = Datastructures.Apronhelper.ApronValue
module ApronExpr : GEx = Datastructures.Apronhelper.ApronExpression
