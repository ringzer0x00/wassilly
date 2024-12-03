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

let add_var = Apronext.Abox.add_var
let assign_expr = Apronext.Abox.assign_texpr
let filter = Apronext.Abox.filter_tcons
let bound_variable = Apronext.Abox.bound_variable
let leq = Apronext.Abox.is_leq
let eq = Apronext.Abox.is_eq
let change_env = Apronext.Abox.change_environment

(*env funcs*)
let make_env = Apronext.Environmentext.make
let forget_env = Apronext.Environmentext.remove
