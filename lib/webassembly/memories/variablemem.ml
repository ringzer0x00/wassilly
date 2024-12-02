module AD = Datastructures.Aprondomain
module AExpr = Datastructures.Aexpr
module WT = Wasm.Types

module MapKey = struct
  type t = { i : Int32.t; t : WT.num_type } (* * WasmVarType *)

  let compare = compare
end

let string_of_nt = function
  | WT.I32Type -> "int32_"
  | WT.I64Type -> "int64_"
  | WT.F32Type -> "float32_"
  | WT.F64Type -> "float64_"

module VariableMem = struct
  module M = Map.Make (MapKey)

  type gl = Glob | Loc
  type aprondomain = AD.dom
  type apronvar = AD.var
  type t = { loc : apronvar M.t; glob : apronvar M.t; ad : aprondomain }
  type binding = M.key
  type expr = AD.expr
  type constr = AD.constr

  let equality (a1 : 'a M.t) (a2 : 'a M.t) =
    if M.compare (fun aa ab -> compare aa ab) a1 a2 = 0 then true else false

  let aprontype_of_wasmtype = function
    | WT.I32Type | WT.I64Type -> Apronext.Environmentext.INT
    | WT.F32Type | WT.F64Type -> Apronext.Environmentext.REAL

  let empty d : t = { loc = M.empty; glob = M.empty; ad = d }

  let find_in_map vm k gl =
    match gl with
    | Glob -> M.filter (fun x _ -> x.i = k) vm.glob
    | Loc -> M.filter (fun x _ -> x.i = k) vm.loc

  let apronvar_of_binding (b : binding) gl : AD.var =
    let aux (b : binding) pre =
      Apron.Var.of_string (pre ^ string_of_nt b.t ^ Int32.to_string b.i)
    in
    match gl with Glob -> aux b "Glob_" | Loc -> aux b "Loc_"

  let string_of_binding ({ i : Int32.t; t : WT.num_type } : binding) =
    string_of_nt t ^ Int32.to_string i

  let assign { loc : apronvar M.t; glob : apronvar M.t; ad : aprondomain } gl b
      exp : t =
    let aux b ma =
      let var = M.find_opt b ma in
      match var with
      | None ->
          Format.printf "bindings len: %i\n" (List.length (M.bindings loc));
          failwith "assignment failed, cannot find key-var"
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
    ignore glob;
    (*raw interval, would returning ref would be appropriate?*)
    let aux b ma =
      let v = M.find_opt b ma in
      match v with None -> failwith "noooo" | Some v -> AD.bound_variable ad v
    in
    match gl with Glob -> aux b glob | Loc -> aux b loc

  let widen (vm1 : t) (vm2 : t) : t =
    if equality vm1.glob vm2.glob && equality vm1.loc vm2.loc then
      let ad' = AD.widen vm1.ad vm2.ad in
      { glob = vm1.glob; loc = vm1.loc; ad = ad' }
    else failwith "not compatible"

  let join (vm1 : t) (vm2 : t) : t =
    if equality vm1.glob vm2.glob && equality vm1.loc vm2.loc then
      let ad' = AD.join vm1.ad vm2.ad in
      { glob = vm1.glob; loc = vm1.loc; ad = ad' }
    else failwith "not compatible"

  let filter vm cons : t =
    { glob = vm.glob; loc = vm.loc; ad = AD.filter vm.ad cons }

  let leq vm1 vm2 =
    if equality vm1.glob vm2.glob && equality vm1.loc vm2.loc then
      AD.leq vm1.ad vm2.ad
    else failwith "not compatible"

  let eq vm1 vm2 =
    if equality vm1.glob vm2.glob && equality vm1.loc vm2.loc then
      AD.eq vm1.ad vm2.ad
    else failwith "not compatible"

  let le (vm1 : t) (vm2 : t) = leq vm1 vm2 && not (eq vm1 vm2)

  let new_ { loc; glob; ad } (locs_new : WT.value_type list) : t =
    let locs_old = M.bindings loc |> List.map snd |> Array.of_list in
    let ad_forgotten = AD.change_env ad (AD.forget_env ad.env locs_old) in
    (*this has to be forgotten, because variables might collide*)
    let globs = M.bindings glob in
    let extract_typed_env_vars (bs : (binding * apronvar) list) =
      List.fold_left
        (fun (i, r) (_b : binding * apronvar) ->
          match (fst _b).t with
          | WT.I32Type | WT.I64Type -> (snd _b :: i, r)
          | WT.F32Type | WT.F64Type -> (i, snd _b :: r))
        ([], []) bs
    in
    let loc_binds =
      List.mapi
        (fun i x ->
          match x with
          | WT.NumType t ->
              let b : binding = { t; i = Int32.of_int i } in
              (b, apronvar_of_binding b Loc)
          | _ -> failwith "cannot do other shiiiit")
        locs_new
    in
    let loc'_int, loc'_real = extract_typed_env_vars loc_binds in
    let glob_int, glob_real = extract_typed_env_vars globs in
    let intvars, realvars =
      ( loc'_int @ glob_int |> Array.of_list,
        loc'_real @ glob_real |> Array.of_list )
    in
    let env' = AD.make_env intvars realvars in
    let ad'' = AD.change_env ad_forgotten env' in
    { loc = M.of_seq (List.to_seq loc_binds); glob; ad = ad'' }

  let return_ (from : t) (to_ : t) : t =
    let locs_from = M.bindings from.loc |> List.map snd |> Array.of_list in
    let _env_ad_from' (*forget locs*) =
      Apronext.Abstractext.change_environment Apronext.Apol.man from.ad
        (Apronext.Environmentext.remove from.ad.env locs_from)
        false
    in
    let globs_to = M.bindings from.glob |> List.map snd |> Array.of_list in
    let _ad_to' (*forget globs*) =
      Apronext.Abstractext.forget_array Apronext.Apol.man to_.ad globs_to false
    in
    let env_lce = Apronext.Environmentext.lce _env_ad_from'.env _ad_to'.env in
    let ad' =
      Apronext.Abstractext.meet Apronext.Apol.man
        (Apronext.Abstractext.change_environment Apronext.Apol.man _env_ad_from'
           env_lce false)
        (Apronext.Abstractext.change_environment Apronext.Apol.man _ad_to'
           env_lce false)
    in
    { loc = to_.loc; glob = to_.glob; ad = ad' }
end
