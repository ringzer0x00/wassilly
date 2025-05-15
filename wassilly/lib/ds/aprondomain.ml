(** Aliases from the [Apronext] library.  **)

type dom = Apronext.Abox.t
type var = Apron.Var.t
type expr = Apronext.Texprext.t
type constr = Apronext.Tconsext.t

let man = Apronext.Abox.man
let join = Apronext.Abox.join

let widen ad1 ad2 =
  let ad' = Apronext.Abox.widening ad1 ad2 in
  let ad'' = Apronext.Abox.widening ad2 ad1 in
  join ad' ad''

let meet = Apronext.Abox.meet

let add_var = Apronext.Abox.add_var
let assign_expr = Apronext.Abox.assign_texpr
let filter = Apronext.Abox.filter_tcons
let bound_variable = Apronext.Abox.bound_variable
let leq = Apronext.Abox.is_leq
let eq = Apronext.Abox.is_eq
let change_env = Apronext.Abox.change_environment

(*env funcs*)
let make_env = Apronext.Environmentext.make
let remove_var_env = Apronext.Environmentext.remove
let forget_existential = Apronext.Abstractext.forget_array Apronext.Abox.man
let is_bottom = Apronext.Abox.is_bottom
let is_top = Apronext.Abox.is_top
let bound_texpr = Apronext.Abstractext.bound_texpr Apronext.Abox.man
let sat_tcons = Apronext.Abox.sat_tcons
let filter_tcons = Apronext.Abox.filter_tcons
let top = Apronext.Abox.top
let bottom = Apronext.Abox.bottom

let lce = Apronext.Environmentext.lce