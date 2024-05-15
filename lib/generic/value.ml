module type GV = sig
  type t

  val compare : t -> t -> int
  (*val lub : t -> t -> t
    val widen : t -> t -> t*)
end

module ApronValue : GV = Datastructures.Apronhelper.ApronValue
