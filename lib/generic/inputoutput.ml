module type InterpreterInput = sig
  (*depends on env*)
  (*env,expr*)
  type env
  type expr
  type t = env * expr

  val env_of_i : t -> env
  val expr_of_i : t -> expr
  val compare : t -> t -> int
  val pred : t -> t -> bool
  val env_leq : env -> env -> bool
  val env_widen : env -> env -> env
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

  let env_of_i i = fst i
  let expr_of_i i = snd i
  let compare = compare
  let pred e i = snd e = snd i
  let env_leq = Env.leq
  let env_widen = Env.widen
end

module InterpreterOutputPure (V : Value.GVal) : InterpreterOutput = struct
  type value = V.t
  type t = value (*interval*)

  let compare = compare
end
