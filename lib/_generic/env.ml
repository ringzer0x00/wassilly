module type GE = sig
  type value
  type alloc
  type typedalloc
  type t

  val make : t
  val add_and_assign : typedalloc -> value -> t -> t
  val lookup : alloc -> t -> value
  val leq : t -> t -> bool
  val lub : t -> t -> t
  val widen : t -> t -> t
  val alloc_of_string : string -> alloc
end

(*
module MapEnv (V : Value.GVal) (A : Alloc.MapAlloc) : GE = struct
  type value = V.t
  type alloc = A.t

  module M = Datastructures.Mapping.Make (A) (V)

  type t = M.t

  let make : t = M.empty
  let add_and_assign a v m = M.add a v m

  let lookup a m =
    match M.find_opt a m with None -> failwith "fail @ lookup" | Some v -> v

  let leq _ _ = failwith ""
  let lub _ _ = failwith ""
  let widen _ _ = failwith ""
end
*)
module ApronEnv (A : Alloc.ApronAlloc) (V: Value.GVal) : GE = struct
  module AA1 = Apron.Abstract1

  type value = Apron.Interval.t
  type alloc = Apron.Var.t
  type typedalloc = A.t

  let mgr = Polka.manager_alloc_strict ()

  type t = Polka.strict Polka.t AA1.t

  let make : t = AA1.top mgr (Apron.Environment.make [||] [||])

  let addvar mgr (aenv : 'a AA1.t) alloc f =
    let env = aenv.env in
    let intarr, realarr, var = f alloc in
    let env' = Apron.Environment.add env intarr realarr in
    let aenv = AA1.change_environment mgr aenv env' false in
    (aenv, var)

  let add_and_assign a _expr m =
    let _m', _var = addvar mgr m a A.to_add in
    failwith ""

  let alloc_of_string = A.of_string
  let lookup a m = AA1.bound_variable mgr m a
  let leq e1 e2 = AA1.is_leq mgr e1 e2
  let lub e1 e2 = AA1.join mgr e1 e2

  let widen e1 e2 =
    let r1 = AA1.widening mgr e1 e2 in
    let r2 = AA1.widening mgr e2 e1 in
    lub r1 r2
end
