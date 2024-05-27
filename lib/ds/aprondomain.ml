type dom = Apronext.Apol.t
type var = Apron.Var.t
type expr = Apronext.Texprext.t
type constr = Apronext.Tconsext.t

let lub = Apronext.Apol.join

let widen ad1 ad2 =
  let ad' = Apronext.Apol.widening ad1 ad2 in
  let ad'' = Apronext.Apol.widening ad2 ad1 in
  lub ad' ad''

let add_var = Apronext.Apol.add_var
let assign_expr = Apronext.Apol.assign_texpr
let filter = Apronext.Apol.filter_tcons
let bound_variable = Apronext.Apol.bound_variable
