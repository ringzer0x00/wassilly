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

module InterpreterInput (Env : Env.GE) (Expr : Language.AST) :
  InterpreterInput = struct
  type env = Env.t
  type expr = Expr.l
  type t = env * expr

  let compare = compare
  let pred e i = snd e = snd i
end

module InterpreterOutputPure (V : Value.GV) : InterpreterOutput = struct
  type value = V.t
  type t = value (*interval*)

  let compare = compare
end
