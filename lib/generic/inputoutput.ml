module type InterpreterInput = sig
  (*depends on env*)
  (*env,expr*)
  type env
  type expr
  type t = env * expr

  val compare : t -> t -> int
  val pred : t -> t -> bool
end

module type InterpreterOutput = sig
  (*val*)
  type t

  val compare : t -> t -> int
end
