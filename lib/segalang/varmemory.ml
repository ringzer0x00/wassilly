module AD = Datastructures.Aprondomain
module AExpr = Datastructures.Aexpr
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
    List.fold_right
      (fun x acc ->
        match x with
        | WT.NumType t ->
            let b : binding = { t; i = Int32.of_int (List.length acc) } in
            (b, apronvar_of_binding b Loc) :: acc
        | _ -> failwith "")
      locs_new []
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
  let globals = M.bindings from.glob |> List.map snd in
  let globs_var_expr =
    List.map
      (fun x ->
        (x, AD.bound_variable from.ad x |> AExpr.of_interval_in_ad from.ad))
      globals
  in
  let ad' =
    List.fold_left
      (fun a (var, value) -> AD.assign_expr a var value)
      to_.ad globs_var_expr
  in
  { loc = to_.loc; glob = to_.glob; ad = ad' }