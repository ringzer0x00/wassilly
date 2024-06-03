module AD = Datastructures.Aprondomain
module WT = Wasm.Types

module MapKey = struct
  type t = { i : Int32.t; t : WT.num_type } (* * WasmVarType *)

  let compare = compare
end

let string_of_nt = function
  | WT.I32Type -> "int32"
  | WT.I64Type -> "int64"
  | WT.F32Type -> "float32"
  | WT.F64Type -> "float64"

module VariableMem = struct
  module M = Map.Make (MapKey)

  type gl = Glob | Loc
  type aprondomain = AD.dom
  type apronvar = AD.var
  type t = { loc : apronvar M.t; glob : apronvar M.t; ad : aprondomain }
  type binding = M.key
  type expr = AD.expr
  type constr = AD.constr

  let aprontype_of_wasmtype = function
    | WT.I32Type | WT.I64Type -> Apronext.Environmentext.INT
    | WT.F32Type | WT.F64Type -> Apronext.Environmentext.REAL

  let empty d : t = { loc = M.empty; glob = M.empty; ad = d }

  let apronvar_of_binding (b : binding) gl : AD.var =
    let aux (b : binding) pre =
      Apron.Var.of_string (pre ^ string_of_nt b.t ^ Int32.to_string b.i)
    in
    match gl with Glob -> aux b "Glob_" | Loc -> aux b "Loc_"

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
      (b : binding) gl (*apron binding type needed*) =
    let add_var ad (b : binding) v =
      let bt = aprontype_of_wasmtype b.t in
      AD.add_var ad bt v
    in
    let aux b ma gl =
      let v = apronvar_of_binding b gl in
      let ad' = add_var ad b v in
      let ma' = M.add b v ma in
      (ma', ad')
    in
    match gl with
    | Glob ->
        let glob', ad' = aux b glob gl in
        { loc; glob = glob'; ad = ad' }
    | Loc ->
        let loc', ad' = aux b loc gl in
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

  let new_context { loc; glob; ad } (_newlocvars : WT.value_type list) : t =
    let _to_forget = M.bindings loc |> List.map snd |> Array.of_list in
    let _ad_forgotten = AD.change_env ad (AD.forget_env ad.env _to_forget) in
    (*this has to be forgotten, because variables might collide*)
    let _typed_to_keep = M.bindings glob in
    let extract_typed_env_vars (bs : (binding * apronvar) list) =
      List.fold_left
        (fun (i, r) (_b : binding * apronvar) ->
          match (fst _b).t with
          | WT.I32Type | WT.I64Type -> (snd _b :: i, r)
          | WT.F32Type | WT.F64Type -> (i, snd _b :: r))
        ([], []) bs
    in
    let _ = AD.change_env in
    (*example*)
    let _new_loc_bindings =
      List.fold_right
        (fun x acc ->
          match x with
          | WT.NumType t ->
              let b : binding = { t; i = Int32.of_int (List.length acc) } in
              (b, apronvar_of_binding b Loc) :: acc
          | _ -> failwith "")
        _newlocvars []
    in
    let int_new, real_new = extract_typed_env_vars _new_loc_bindings in
    let _int_avar, _real_avar = extract_typed_env_vars _typed_to_keep in
    (* make list of intvar, realvars from _newlocvars: note that the index number is part of the binding*)
    let _ = ad in
    failwith "make a new map, create env on top of that"

  let return_context (_in : t) (_to : t) : t =
    (*for all globals in _in:
        - grab apron bindings -> concretize them,
        - turn them into expressione
        - assign in _to
    *)
    failwith "concretize globals, assign them to the ~ad we're going back to~"
end

(* val change_environment : 'a Manager.t -> 'a t -> Environment.t -> bool -> 'a t

   Change the environment of the abstract values.

   Variables that are removed are first existentially quantified, and variables that are introduced are unconstrained. The Boolean, if true, adds a projection onto 0-plane for these ones.
*)
