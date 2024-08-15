open Memories.Operand
module I = Apronext.Intervalext
module S = Apronext.Scalarext

let const (n : Wasm.Ast.num) (vm : varmemories) =
  let v, t =
    match n.it with
    | F32 c ->
        let c = Wasm.F32.to_float c in
        (I.of_float c c, Wasm.Types.F32Type)
    | F64 c ->
        let c = Wasm.F64.to_float c in
        (I.of_float c c, Wasm.Types.F64Type)
    | I32 c ->
        let c = Wasm.I32.to_int_s c in
        Printf.printf "\n\nConst: %i\n" c;
        let interval = I.of_int c c in
        I.print Format.std_formatter interval;
        (interval, Wasm.Types.I32Type)
    | I64 c ->
        let c = Wasm.I64.to_int_s c in
        (I.of_int c c, Wasm.Types.I64Type)
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
  match Apronext.Intervalext.equal_int (concretize vm r) 0 with
  | true -> failwith "div by zero"
  | false ->
      Expression
        ( Apronext.Texprext.binary Apronext.Texprext.Div l_ex r_ex,
          type_of_operand l )

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
  Expression
    (Apronext.Texprext.unary Apronext.Texprext.Sqrt o_ex, type_of_operand o)

let abs_expr vm o =
  let bigger x y = match S.cmp x y < 0 with true -> y | false -> x in
  let max = I.of_scalar (S.of_int 0) (S.of_infty 1) in
  let ival, t = (concretize vm o, type_of_operand o) in
  let inf, sup = (ival.inf, ival.sup) in
  let r =
    match I.is_top ival with
    | true -> max
    | false -> (
        match (S.sgn inf, S.sgn sup) with
        (*-1: negative, 0: null(zero), +1: positive*)
        | 0, 0 | 0, 1 | 1, 1 -> ival
        | -1, 0 -> I.of_scalar (S.of_int 0) (S.neg inf)
        | -1, 1 -> I.of_scalar (S.of_int 0) (bigger (S.neg inf) sup)
        | 1, -1 -> failwith "bottom interval"
        | _ -> failwith "there shouldnt be any other combination")
  in
  Expression (const_expr vm r, t)

let ge_s_expr vm l r =
  let l_ex = operand_to_expr vm l in
  let r_ex = operand_to_expr vm r in
  BooleanExpression (Apronext.Tconsext.geq (*~typ:Apron.Texpr0.Int*) l_ex r_ex)

let ge_u_expr vm l r =
  let _l_ex = operand_to_expr vm l in
  let _r_ex = operand_to_expr vm r in
  let _t = size_of_type (type_of_operand l) in
  failwith
    "BooleanExpression (Apronext.Tconsext.geq (*~typ:Apron.Texpr0.Int*) l_ex \
     r_ex)"

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

let popcnt_expr vm o =
  let _i = Memories.Operand.concretize vm o in
  let _l_ex = Language.Bitwisenumber.of_interval _i (type_of_operand o) in
  let _abit = Datastructures.Abstractbyte.of_min_max _l_ex.min _l_ex.max in
  let _rmin, _rmax = Bitwisealu.popcount _abit in
  let v = I.of_int _rmin _rmax in
  Expression (const_expr vm v, _l_ex.t)

let clz_expr vm o =
  let _i = Memories.Operand.concretize vm o in
  let _l_ex = Language.Bitwisenumber.of_interval _i (type_of_operand o) in
  let _abit = Datastructures.Abstractbyte.of_min_max _l_ex.min _l_ex.max in
  let _rmin, _rmax = Bitwisealu.clz _abit in
  let v = I.of_int _rmin _rmax in
  Expression (const_expr vm v, _l_ex.t)

let ctz_expr vm o =
  let _i = Memories.Operand.concretize vm o in
  let _l_ex = Language.Bitwisenumber.of_interval _i (type_of_operand o) in
  let _abit = Datastructures.Abstractbyte.of_min_max _l_ex.min _l_ex.max in
  let _rmin, _rmax = Bitwisealu.ctz _abit in
  let v = I.of_int _rmin _rmax in
  Expression (const_expr vm v, _l_ex.t)

let land_expr vm _o1 _o2 =
  let _l, _r =
    (Memories.Operand.concretize vm _o1, Memories.Operand.concretize vm _o2)
  in
  let _l_ex, _r_ex =
    ( Language.Bitwisenumber.of_interval _l (type_of_operand _o1),
      Language.Bitwisenumber.of_interval _r (type_of_operand _o2) )
  in
  let _labit, _rabit =
    ( Datastructures.Abstractbyte.of_min_max _l_ex.min _l_ex.max,
      Datastructures.Abstractbyte.of_min_max _r_ex.min _r_ex.max )
  in
  let _rmin, _rmax = Bitwisealu.l_and _labit _rabit in
  let v = I.of_int _rmin _rmax in
  Expression (const_expr vm v, _l_ex.t)

let lor_expr vm _o1 _o2 =
  let _l, _r =
    (Memories.Operand.concretize vm _o1, Memories.Operand.concretize vm _o2)
  in
  let _l_ex, _r_ex =
    ( Language.Bitwisenumber.of_interval _l (type_of_operand _o1),
      Language.Bitwisenumber.of_interval _r (type_of_operand _o2) )
  in
  let _labit, _rabit =
    ( Datastructures.Abstractbyte.of_min_max _l_ex.min _l_ex.max,
      Datastructures.Abstractbyte.of_min_max _r_ex.min _r_ex.max )
  in
  let _rmin, _rmax = Bitwisealu.l_or _labit _rabit in
  let v = I.of_int _rmin _rmax in
  Expression (const_expr vm v, _l_ex.t)

let lxor_expr vm _o1 _o2 =
  let _l, _r =
    (Memories.Operand.concretize vm _o1, Memories.Operand.concretize vm _o2)
  in
  let _l_ex, _r_ex =
    ( Language.Bitwisenumber.of_interval _l (type_of_operand _o1),
      Language.Bitwisenumber.of_interval _r (type_of_operand _o2) )
  in
  let _labit, _rabit =
    ( Datastructures.Abstractbyte.of_min_max _l_ex.min _l_ex.max,
      Datastructures.Abstractbyte.of_min_max _r_ex.min _r_ex.max )
  in
  let _rmin, _rmax = Bitwisealu.l_xor _labit _rabit in
  let v = I.of_int _rmin _rmax in
  Expression (const_expr vm v, _l_ex.t)

let lshift_expr vm l r =
  let _by = Memories.Operand.concretize vm r in
  let l_i = Memories.Operand.concretize vm l in
  let lb = Language.Bitwisenumber.of_interval l_i (type_of_operand l) in
  let _lb = Datastructures.Abstractbyte.of_min_max lb.min lb.max in
  match S.equal_int (I.range _by) 0 with (*range == 0*)
  | true -> failwith "actually peform shift"
  | false -> Expression (const_expr vm I.top, type_of_operand l)
