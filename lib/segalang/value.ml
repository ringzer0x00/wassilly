type value = Apron.Interval.t
let top = Apron.Interval.top
let bot = Apron.Interval.bottom
let pinf = Apron.Scalar.of_infty 1
let ninf = Apron.Scalar.of_infty (-1)
let makeval inf sup = Apron.Interval.of_scalar inf sup
let of_int32 i = makeval (Apron.Scalar.of_int (Int32.to_int i)) (Apron.Scalar.of_int (Int32.to_int i))

let max x y =
  let comp = Apron.Scalar.cmp x y >= 0 in
  match comp with true -> x | false -> y

let min x y =
  let comp = Apron.Scalar.cmp x y >= 0 in
  match comp with true -> y | false -> x

let lub (i1 : value) (i2 : value) : value =
  Format.print_string "VALUE JOIN:\n";
  Apron.Interval.print Format.std_formatter i1;
  Apron.Interval.print Format.std_formatter i2;
  Format.print_string "\n\n RESULT (join):";
  let r = Apron.Interval.of_scalar (min i1.inf i2.inf) (max i1.sup i2.sup) in
  Apron.Interval.print Format.std_formatter r;
  r

let valueWidening (smaller : value) (bigger : value) : value =
  match (Apron.Interval.is_bottom smaller, Apron.Interval.is_bottom bigger) with
  | true, true -> smaller
  | true, false -> bigger
  | false, true -> failwith "widen something with bottom"
  | false, false ->
      let (smaller_l, smaller_u), (bigger_l, bigger_u) =
        ((smaller.inf, smaller.sup), (bigger.inf, bigger.sup))
      in
      let lower' = if bigger_l < smaller_l then ninf else bigger_l in
      let upper' = if bigger_u > smaller_u then pinf else bigger_u in
      Apron.Interval.of_scalar lower' upper'

let included (l : value) (r : value) : bool = Apron.Interval.is_leq l r

let eq l r =
  (Apron.Interval.is_bottom l && Apron.Interval.is_bottom r)
  || Apron.Interval.equal l r

let smaller (l : value) (r : value) : bool = included l r && not (eq l r)
let to_string _v = failwith "tostring"

let to_expr e (_v : Apron.Interval.t) =
  Apron.Texpr1.cst e (Apron.Coeff.Interval _v)

let print v = Apron.Interval.print Format.std_formatter v
