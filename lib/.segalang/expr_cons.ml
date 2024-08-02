module TE = Apronext.Texprext
module TC = Apronext.Tconsext

type exp = TE.t
type con = TC.t

let exp_of_value (v : Value.value) _ad_env =
  TE.cst _ad_env (Apron.Coeff.Interval v)

let cons_of_exp (e : exp) typ = TC.make e typ
let value_of_exp (e : exp) ad env = Apronext.Abstractext.bound_texpr ad env e

let lub _ _ =
  failwith
    "(*call value_of_exp and then the Value.bnlabla counterpart, re-wrap into \
     expression*)"

let widen _ _ = failwith "exprwiden"
let included _ _ = failwith "incexopr"
let eq _ _ = failwith "eqexp"
