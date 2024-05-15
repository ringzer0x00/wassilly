module type GE = sig
  type value
  type alloc
  type t

  val make : t
  val add : alloc -> value -> t -> t
  val lookup : alloc -> t -> value
  (*val lub : t -> t -> t
    val widen : t -> t -> t*)
end

module MapEnv (V : Value.GV) (A : Alloc.MapAlloc) : GE = struct
  type value = V.t
  type alloc = A.t

  module M = Datastructures.Mapping.Make (A) (V)

  type t = M.t

  let make : t = M.empty
  let add a v m = M.add a v m

  let lookup a m =
    match M.find_opt a m with None -> failwith "fail @ lookup" | Some v -> v
end

module ApronEnv (A : Alloc.ApronAlloc) : GE = struct
  module V = Value.ApronValue
  module AH = Datastructures.Apronhelper.ApronEnvHelper

  type value = V.t
  type alloc = A.t

  let mgr = Polka.manager_alloc_strict ()

  type t = Polka.strict Polka.t Apron.Abstract1.t

  let make : t = AH.make mgr

  let add _a _v _m =
    let _e' = AH.add mgr _m _a A.to_add in
    failwith ""

  let lookup _ _ = failwith ""
end
