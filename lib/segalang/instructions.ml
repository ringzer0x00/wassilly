open Memory
open Lowlevel_instrs

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

let brpeek prec n =
  match prec with
  | Bot -> raise Labelstack.EmptyStack
  | Def d -> Labelstack.peek_nth n d.lsk

let br prec n =
  prec >>= fun d ->
  return
    {
      vm = d.vm;
      opsk = d.opsk;
      lsk =
        (if Labelstack.is_empty d.lsk then raise Labelstack.EmptyStack
         else Labelstack.pop_n (n + 1) d.lsk);
    }

let const_val _v prec =
  prec >>= fun d ->
  return
    {
      vm = d.vm;
      lsk = d.lsk;
      opsk = Operandstack.push_ops [ Value.of_int32 _v ] d.opsk;
    }

let mul prec =
  prec >>= fun d ->
  let opsk' = Operandstack.binop d.opsk (fun x y -> mul_expr d.vm.ad x y) in
  return { vm = d.vm; lsk = d.lsk; opsk = opsk' }

let add prec =
  prec >>= fun d ->
  let opsk' = Operandstack.binop d.opsk (fun x y -> add_expr d.vm.ad x y) in
  return { vm = d.vm; lsk = d.lsk; opsk = opsk' }

let sub prec =
  prec >>= fun d ->
  let opsk' = Operandstack.binop d.opsk (fun x y -> sub_expr d.vm.ad x y) in
  return { vm = d.vm; lsk = d.lsk; opsk = opsk' }

let neg prec =
  prec >>= fun d ->
  let opsk' = Operandstack.unop d.opsk (fun x -> neg_expr d.vm.ad x) in
  return { vm = d.vm; lsk = d.lsk; opsk = opsk' }

let intbool prec =
  match prec with
  | Bot -> failwith "come on pls leave me alone fucking io monad"
  | Def d ->
      let v, opsk' = Operandstack.intbool d.opsk in
      (Def { vm = d.vm; lsk = d.lsk; opsk = opsk' }, v)
