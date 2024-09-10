module type LV = sig
  include Baselattice.L

  type dt
  type vartype
  type varid

  val makeEnv : varid array -> varid array -> env
  val addVar : t -> vartype -> varid -> t
  val addVarString : t -> vartype -> string -> t
  val envLub : env -> env -> env
  val envMeet : env -> env -> env
  val mgr : dt Apron.Manager.t
end
