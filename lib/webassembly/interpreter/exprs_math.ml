open Memories.Operand

let const (n : Wasm.Ast.num) (vm : varmemories) =
  let v, t =
    match n.it with
    | F32 c ->
        let c = Wasm.F32.to_float c in
        (Apronext.Intervalext.of_float c c, Wasm.Types.F32Type)
    | F64 c ->
        let c = Wasm.F64.to_float c in
        (Apronext.Intervalext.of_float c c, Wasm.Types.F64Type)
    | I32 c ->
        let c = Wasm.I32.to_int_s c in
        Printf.printf "\n\nConst: %i\n" c;
        let interval = Apronext.Intervalext.of_int c c in
        Apronext.Intervalext.print Format.std_formatter interval;
        (interval, Wasm.Types.I32Type)
    | I64 c ->
        let c = Wasm.I64.to_int_s c in
        (Apronext.Intervalext.of_int c c, Wasm.Types.I64Type)
  in
  Expression (const_expr vm v, t)

let mul_expr vm l r =
  let l_ex = operand_to_expr vm l in
  let r_ex = operand_to_expr vm r in
  Expression
    (Apronext.Texprext.binary Apronext.Texprext.Mul l_ex r_ex, type_of_operand l)

let divs_expr vm l r =
  let l_ex = operand_to_expr vm l in
  let r_ex = operand_to_expr vm r in
  Expression
    (Apronext.Texprext.binary Apronext.Texprext.Div l_ex r_ex, type_of_operand l)

let rems_expr vm l r =
  let l_ex = operand_to_expr vm l in
  let r_ex = operand_to_expr vm r in
  Expression
    (Apronext.Texprext.binary Apronext.Texprext.Mod l_ex r_ex, type_of_operand l)

let add_expr vm l r =
  let l_ex = operand_to_expr vm l in
  let r_ex = operand_to_expr vm r in
  let ex = Apronext.Texprext.binary Apronext.Texprext.Add l_ex r_ex in
  Printf.printf "Expression:\n";
  Apronext.Texprext.print_expr Format.std_formatter
    (Apronext.Texprext.to_expr ex);
  Printf.printf "\n";

  Expression (ex, type_of_operand l)

let sub_expr vm l r =
  let l_ex = operand_to_expr vm l in
  let r_ex = operand_to_expr vm r in
  Expression
    (Apronext.Texprext.binary Apronext.Texprext.Sub l_ex r_ex, type_of_operand l)

let neg_expr vm o =
  let o_ex = operand_to_expr vm o in
  Expression
    (Apronext.Texprext.unary Apronext.Texprext.Neg o_ex, type_of_operand o)

let sqrt_expr vm o =
  let o_ex = operand_to_expr vm o in
  Expression (Apronext.Texprext.unary Apronext.Texprext.Sqrt o_ex, type_of_operand o)

let ge_s_expr vm l r =
  let l_ex = operand_to_expr vm l in
  let r_ex = operand_to_expr vm r in
  BooleanExpression (Apronext.Tconsext.geq (*~typ:Apron.Texpr0.Int*) l_ex r_ex)

let gt_s_expr vm l r =
  let l_ex = operand_to_expr vm l in
  let r_ex = operand_to_expr vm r in
  BooleanExpression (Apronext.Tconsext.gt (*~typ:Apron.Texpr0.Int*) l_ex r_ex)

let lt_s_expr vm l r =
  let l_ex = operand_to_expr vm l in
  let r_ex = operand_to_expr vm r in
  BooleanExpression (Apronext.Tconsext.lt (*~typ:Apron.Texpr0.Int*) l_ex r_ex)

let le_s_expr vm l r =
  let l_ex = operand_to_expr vm l in
  let r_ex = operand_to_expr vm r in
  BooleanExpression (Apronext.Tconsext.leq l_ex r_ex)

let eq_expr vm l r =
  let l_ex = operand_to_expr vm l in
  let r_ex = operand_to_expr vm r in
  BooleanExpression (Apronext.Tconsext.eq l_ex r_ex)

let ne_expr vm l r =
  let l_ex = operand_to_expr vm l in
  let r_ex = operand_to_expr vm r in
  BooleanExpression (Apronext.Tconsext.diseq l_ex r_ex)

let eqz_expr vm o =
  let l_ex = operand_to_expr vm o in
  BooleanExpression (Apronext.Tconsext.make l_ex Apronext.Tconsext.EQ)
