open Memory

let mul_expr (ad : VM.aprondomain) (l : Value.value) (r : Value.value) =
  let exp =
    Apronext.Texprext.binary Apronext.Texprext.Mul
      (Apronext.Texprext.cst ad.env (Apron.Coeff.Interval l))
      (Apronext.Texprext.cst ad.env (Apron.Coeff.Interval r))
  in
  Apronext.Abstractext.bound_texpr Apronext.Apol.man ad exp

let add_expr (ad : VM.aprondomain) (l : Value.value) (r : Value.value) =
  let exp =
    Apronext.Texprext.binary Apronext.Texprext.Add
      (Apronext.Texprext.cst ad.env (Apron.Coeff.Interval l))
      (Apronext.Texprext.cst ad.env (Apron.Coeff.Interval r))
  in
  Apronext.Abstractext.bound_texpr Apronext.Apol.man ad exp

let sub_expr (ad : VM.aprondomain) (l : Value.value) (r : Value.value) =
  let exp =
    Apronext.Texprext.binary Apronext.Texprext.Sub
      (Apronext.Texprext.cst ad.env (Apron.Coeff.Interval l))
      (Apronext.Texprext.cst ad.env (Apron.Coeff.Interval r))
  in
  Apronext.Abstractext.bound_texpr Apronext.Apol.man ad exp

let neg_expr (ad : VM.aprondomain) (v : Value.value) =
  let exp =
    Apronext.Texprext.unary Apronext.Texprext.Neg
      (Apronext.Texprext.cst ad.env (Apron.Coeff.Interval v))
  in
  Apronext.Abstractext.bound_texpr Apronext.Apol.man ad exp
