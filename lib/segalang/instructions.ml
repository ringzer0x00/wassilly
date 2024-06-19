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
  let mul = mul_expr d.vm.ad in
  let opsk' = Operandstack.binop d.opsk mul in
  return { vm = d.vm; lsk = d.lsk; opsk = opsk' }
