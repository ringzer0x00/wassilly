module type GE = sig
  type value
  type alloc
  type t

  val make : t
  val add : alloc -> value -> t -> t
  val lookup : alloc -> t -> value
  val leq : t -> t -> bool
  val lub : t -> t -> t
  val widen : t -> t -> t
end

module MapEnv (V : Value.GVal) (A : Alloc.MapAlloc) : GE = struct
  type value = V.t
  type alloc = A.t

  module M = Datastructures.Mapping.Make (A) (V)

  type t = M.t

  let make : t = M.empty
  let add a v m = M.add a v m

  let lookup a m =
    match M.find_opt a m with None -> failwith "fail @ lookup" | Some v -> v

  let leq _ _ = failwith ""
  let lub _ _ = failwith ""
  let widen _ _ = failwith ""
end

module ApronEnv (A : Alloc.ApronAlloc) : GE = struct
  module V = Value.ApronValue (*this has to become an expression!*)
  module AH = Datastructures.Apronhelper.ApronEnvHelper

  type value = Apron.Interval.t
  type alloc = A.t

  let mgr = Polka.manager_alloc_strict ()

  type t = Polka.strict Polka.t Apron.Abstract1.t

  let make : t = AH.make mgr

  let add _a _expr _m =
    let _m', _var = AH.add_and_assign mgr _m _a A.to_add in
    failwith ""

  let lookup a m = Apron.Abstract1.bound_variable mgr m (A.var_of_alloc a)
  let leq e1 e2 = Apron.Abstract1.is_leq mgr e1 e2
  let lub e1 e2 = Apron.Abstract1.join mgr e1 e2
  let widen e1 e2 = Apron.Abstract1.widening mgr e1 e2
end
