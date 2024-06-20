open Memory

let bind x op = match x with Bot -> Bot | Def a -> op a
let ( >>= ) = bind

let enter_block bl (prec : t) =
  prec >>= fun d ->
  return { vm = d.vm; opsk = d.opsk; lsk = Labelstack.push bl d.lsk }

let end_of_block prec =
  prec >>= fun d ->
  return
    {
      vm = d.vm;
      opsk = d.opsk;
      lsk =
        (if Labelstack.is_empty d.lsk then d.lsk else Labelstack.pop_n 1 d.lsk);
    }

let const_val _v prec =
  prec >>= fun d ->
  return
    {
      vm = d.vm;
      lsk = d.lsk;
      opsk = Operandstack.push_ops [ Value.of_int32 _v ] d.opsk;
    }

let mul_expr (ad : VM.aprondomain) (l : Value.value) (r : Value.value) =
  let exp =
    Apronext.Texprext.binary Apronext.Texprext.Mul
      (Apronext.Texprext.cst ad.env (Apron.Coeff.Interval l))
      (Apronext.Texprext.cst ad.env (Apron.Coeff.Interval r))
  in
  Apronext.Abstractext.bound_texpr Apronext.Apol.man ad exp

let mul prec =
  prec >>= fun d ->
  let opsk' = Operandstack.binop d.opsk (fun x y -> mul_expr d.vm.ad x y) in
  return { vm = d.vm; lsk = d.lsk; opsk = opsk' }

let add_expr (ad : VM.aprondomain) (l : Value.value) (r : Value.value) =
  let exp =
    Apronext.Texprext.binary Apronext.Texprext.Add
      (Apronext.Texprext.cst ad.env (Apron.Coeff.Interval l))
      (Apronext.Texprext.cst ad.env (Apron.Coeff.Interval r))
  in
  Apronext.Abstractext.bound_texpr Apronext.Apol.man ad exp

let add prec =
  prec >>= fun d ->
  let add = add_expr d.vm.ad in
  let opsk' = Operandstack.binop d.opsk add in
  return { vm = d.vm; lsk = d.lsk; opsk = opsk' }

let sub_expr (ad : VM.aprondomain) (l : Value.value) (r : Value.value) =
  let exp =
    Apronext.Texprext.binary Apronext.Texprext.Sub
      (Apronext.Texprext.cst ad.env (Apron.Coeff.Interval l))
      (Apronext.Texprext.cst ad.env (Apron.Coeff.Interval r))
  in
  Apronext.Abstractext.bound_texpr Apronext.Apol.man ad exp

let sub prec =
  prec >>= fun d ->
  let sub = sub_expr d.vm.ad in
  let opsk' = Operandstack.binop d.opsk sub in
  return { vm = d.vm; lsk = d.lsk; opsk = opsk' }

let neg_expr (ad : VM.aprondomain) (v : Value.value) =
  let exp =
    Apronext.Texprext.unary Apronext.Texprext.Neg
      (Apronext.Texprext.cst ad.env (Apron.Coeff.Interval v))
  in
  Apronext.Abstractext.bound_texpr Apronext.Apol.man ad exp

let neg prec =
  prec >>= fun d ->
  let neg = neg_expr d.vm.ad in
  let opsk' = Operandstack.unop d.opsk neg in
  return { vm = d.vm; lsk = d.lsk; opsk = opsk' }
