type dom = Apronext.Apol.t
type var = Apron.Var.t
type expr = Apronext.Texprext.t
type constr = Apronext.Tconsext.t

let widen = Apronext.Apol.widening
let lub = Apronext.Apol.join
let add_var = Apronext.Apol.add_var
let assign_expr = Apronext.Apol.assign_texpr

let filter = Apronext.Apol.filter_tcons