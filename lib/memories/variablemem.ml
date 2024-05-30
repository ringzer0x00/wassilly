module AD = Datastructures.Aprondomain

module MapKey = struct
  type t = Int32.t (* * type *)

  let compare = compare
end

module VariableMem = struct
  module M = Map.Make (MapKey)

  type gl = Glob | Loc
  type aprondomain = AD.dom
  type apronvar = AD.var
  type t = { loc : apronvar M.t; glob : apronvar M.t; ad : aprondomain }
  type binding = M.key
  type expr = AD.expr
  type constr = AD.constr

  let empty d : t = { loc = M.empty; glob = M.empty; ad = d }

  let apronvar_of_binding (b : M.key) : AD.var =
    Apron.Var.of_string (Int32.to_string b)

  let assign { loc : apronvar M.t; glob : apronvar M.t; ad : aprondomain } gl b
      exp : t =
    let aux b ma =
      let var = M.find_opt b ma in
      match var with
      | None -> failwith "assignment failed, cannot find key-var"
      | Some var -> (ma, AD.assign_expr ad var exp)
    in
    match gl with
    | Glob ->
        let glob', ad' = aux b glob in
        { loc; glob = glob'; ad = ad' }
    | Loc ->
        let loc', ad' = aux b loc in
        { loc = loc'; glob; ad = ad' }

  let bind { loc : apronvar M.t; glob : apronvar M.t; ad : aprondomain }
      (b : binding) gl bt (*apron binding type needed*) =
    let aux b ma =
      let v = apronvar_of_binding b in
      let ad' = AD.add_var ad bt v in
      let ma' = M.add b v ma in
      (ma', ad')
    in
    match gl with
    | Glob ->
        let glob', ad' = aux b glob in
        { loc; glob = glob'; ad = ad' }
    | Loc ->
        let loc', ad' = aux b loc in
        { loc = loc'; glob; ad = ad' }

  let lookup { loc : apronvar M.t; glob : apronvar M.t; ad : aprondomain }
      (b : binding) gl : Apronext.Intervalext.t =
    (*raw interval, would returning ref would be appropriate?*)
    let aux b ma =
      let v = M.find_opt b ma in
      match v with None -> failwith "noooo" | Some v -> AD.bound_variable ad v
    in
    match gl with Glob -> aux b glob | Loc -> aux b loc

  let widen (vm1 : t) (vm2 : t) : t =
    if vm1.glob = vm2.glob && vm2.loc = vm2.loc then
      let ad' = AD.widen vm1.ad vm2.ad in
      { glob = vm1.glob; loc = vm1.loc; ad = ad' }
    else failwith "not compatible"

  let join (vm1 : t) (vm2 : t) : t =
    if vm1.glob = vm2.glob && vm2.loc = vm2.loc then
      let ad' = AD.join vm1.ad vm2.ad in
      { glob = vm1.glob; loc = vm1.loc; ad = ad' }
    else failwith "not compatible"

  let filter vm cons : t =
    { glob = vm.glob; loc = vm.loc; ad = AD.filter vm.ad cons }

  let leq vm1 vm2 =
    if vm1.glob = vm2.glob && vm2.loc = vm2.loc then AD.leq vm1.ad vm2.ad
    else failwith "not compatible"

  let eq vm1 vm2 =
    if vm1.glob = vm2.glob && vm2.loc = vm2.loc then AD.eq vm1.ad vm2.ad
    else failwith "not compatible"

  let le (vm1 : t) (vm2 : t) = leq vm1 vm2 && not (eq vm1 vm2)
  let return_context (_ : t) (_ : t) : t = failwith ""
end

(* val change_environment : 'a Manager.t -> 'a t -> Environment.t -> bool -> 'a t

   Change the environment of the abstract values.

   Variables that are removed are first existentially quantified, and variables that are introduced are unconstrained. The Boolean, if true, adds a projection onto 0-plane for these ones.
*)
