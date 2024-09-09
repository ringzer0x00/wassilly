module type L = sig
  type t
  type env
  type man

  val mgr : man
  val top : env -> t
  val bottom : env -> t
  val lub : t -> t -> t
  val widen : t -> t -> t
  val meet : t -> t -> t
  val partialOrder : t -> t -> bool
  val toString : t -> string
  val print : t -> unit
end
