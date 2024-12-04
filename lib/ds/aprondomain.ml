(** Aliases from the [Apronext] library.  **)

type dom = Apronext.Apol.t
type var = Apron.Var.t
type expr = Apronext.Texprext.t
type constr = Apronext.Tconsext.t

let man = Apronext.Apol.man
let join = Apronext.Apol.join

let widen ad1 ad2 =
  let ad' = Apronext.Apol.widening ad1 ad2 in
  let ad'' = Apronext.Apol.widening ad2 ad1 in
  join ad' ad''

let meet = Apronext.Apol.meet

let add_var = Apronext.Apol.add_var
let assign_expr = Apronext.Apol.assign_texpr
let filter = Apronext.Apol.filter_tcons
let bound_variable = Apronext.Apol.bound_variable
let leq = Apronext.Apol.is_leq
let eq = Apronext.Apol.is_eq
let change_env = Apronext.Apol.change_environment

(*env funcs*)
let make_env = Apronext.Environmentext.make
let forget_env = Apronext.Abstractext.forget_array Apronext.Apol.man
let is_bottom = Apronext.Apol.is_bottom
let is_top = Apronext.Apol.is_top
let bound_texpr = Apronext.Abstractext.bound_texpr Apronext.Apol.man
let sat_tcons = Apronext.Apol.sat_tcons
let filter_tcons = Apronext.Apol.filter_tcons
let top = Apronext.Apol.top
let bottom = Apronext.Apol.bottom

let lce = Apronext.Environmentext.lce