module AD = Datastructures.Aprondomain

module MapKey = struct
  type t = Int32.t

  let compare = compare
end

module VariableMem = struct
  module M = Map.Make (MapKey)

  type aprondomain = AD.dom
  type apronvar = AD.var
  type t = apronvar M.t * aprondomain
  type binding = M.key
  type expr = AD.expr
  type constr = AD.constr

  let empty d : t = (M.empty, d)

  let apronvar_of_binding (b : int32) : AD.var =
    Apron.Var.of_string (Int32.to_string b)

  let assign ((ma, ad) : t) b exp : t =
    let var = M.find_opt b ma in
    match var with
    | None -> failwith "assignment failed, cannot find key-var"
    | Some var -> (ma, AD.assign_expr ad var exp)

  let bind ((ma, ad) : t) (b : binding) bt (*apron binding type needed*) =
    let v = apronvar_of_binding b in
    let ad' = AD.add_var ad bt v in
    let ma' = M.add b v ma in
    (ma', ad')

  let lookup ((ma, ad) : t) (b : binding) : Apronext.Intervalext.t =
    (*raw interval, would returning ref would be appropriate?*)
    let v = M.find_opt b ma in
    match v with None -> failwith "noooo" | Some v -> AD.bound_variable ad v

  let widen ((ma1, ad1) : t) ((ma2, ad2) : t) : t =
    if ma1 = ma2 then
      let ad' = AD.widen ad1 ad2 in
      (ma1, ad')
    else failwith "not compatible"

  let join ((ma1, ad1) : t) ((ma2, ad2) : t) : t =
    if ma1 = ma2 then
      let ad' = AD.lub ad1 ad2 in
      (ma1, ad')
    else failwith "not compatible"

  let filter ((ma, ad) : t) cons : t = (ma, AD.filter ad cons)
end

module LocalVar = VariableMem
module GlobalVar = VariableMem
