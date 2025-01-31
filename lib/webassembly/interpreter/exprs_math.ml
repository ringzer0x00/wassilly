open Memories.Operand
module I = Apronext.Intervalext
module S = Apronext.Scalarext

exception NoValidWritesExn

let printer a b = Utilities.Printer.print a b
let listmap' = Utilities.List_.listmap'
let tappl = Utilities.Tuple.tuple_appl

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
        (I.of_int c c, Wasm.Types.I32Type)
    | I64 c ->
        let c = Wasm.I64.to_int_s c in
        (I.of_int c c, Wasm.Types.I64Type)
  in
  Expression (const_expr vm v, t)

let unsign vm o =
  let _i = concretize vm o in
  (*let max =
      match type_of_operand o with
      | Wasm.Types.I32Type -> 4294967295
      | I64Type -> failwith ""
      | _ -> failwith "not supported in unsign"
    in
    let inf, sup = (i.inf, i.sup) in
    let n' n = if S.cmp n (S.of_int 0) < 0 then max + 1 + n else n in*)
  (*let a,b = (n' inf), (n' sup)*)
  (*if a > b then Interval b a else Interval a b*)
  failwith ""

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

let cmpstub_expr vm _ _ =
  let i = I.of_int 0 1 in
  Expression (const_expr vm i, Wasm.Types.I32Type)

let eqz_expr vm o =
  let l_ex = operand_to_expr vm o in
  printer Format.print_string "\t EqZ:";
  printer (Apronext.Texprext.print Format.std_formatter) l_ex;
  printer Format.print_newline ();
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
  printer Format.print_string "\t~ Operands:(";
  printer Memories.Operand.print_operand _o1;
  printer Format.print_string ",";
  printer Memories.Operand.print_operand _o2;
  printer Format.print_string ")\n";
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
  (*Printf.printf "l: %i, r:%i\n" (Array.length _labit) (Array.length _rabit);*)
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

let select_expr vm fst snd trd (_rt : Wasm.Types.value_type list option) =
  let _rt =
    match _rt with
    | None -> type_of_operand fst
    | Some _ -> failwith "some @ select_expr"
  in
  let zero_interval = Apronext.Intervalext.of_int 0 0 in
  let fst_i = concretize vm fst in
  let snd_i = concretize vm snd in
  let trd_i = concretize vm trd in
  if Apronext.Intervalext.equal fst_i zero_interval then snd
  else Expression (const_expr vm (Apronext.Intervalext.join trd_i snd_i), _rt)

let shift_stub_expr vm l _ = Expression (const_expr vm I.top, type_of_operand l)
let load_stub_expr vm ty = Expression (const_expr vm I.top, ty)

let lshift_expr vm l r =
  let _by = Memories.Operand.concretize vm r in
  let l_i = Memories.Operand.concretize vm l in
  let lb = Language.Bitwisenumber.of_interval l_i (type_of_operand l) in
  let lb = Datastructures.Abstractbyte.of_min_max lb.min lb.max in
  match I.is_bounded _by with
  | false -> Expression (const_expr vm I.top, type_of_operand l)
  | true -> (
      match S.equal_int (I.range _by) 0 with
      (*range == 0*)
      | true ->
          let _r =
            Bitwisealu.shift_left lb (Float.to_int (S.to_float _by.inf))
          in
          let min, max =
            Datastructures.Abstractbyte.as_int_arrays _r ~signed:true
          in
          let ival =
            match Array.length min with
            | 32 ->
                let mi, ma =
                  ( Utilities.Conversions.int32_binary_to_decimal
                      (Array.to_list min),
                    Utilities.Conversions.int32_binary_to_decimal
                      (Array.to_list max) )
                in
                Apronext.Intervalext.of_int
                  (Int32.min mi ma |> Int32.to_int)
                  (Int32.max mi ma |> Int32.to_int)
            | 64 ->
                let mi, ma =
                  ( Utilities.Conversions.int64_binary_to_decimal
                      (Array.to_list min),
                    Utilities.Conversions.int64_binary_to_decimal
                      (Array.to_list max) )
                in
                let mi, ma =
                  ( Int64.to_string (Int64.min mi ma),
                    Int64.to_string (Int64.max mi ma) )
                in
                Apronext.Intervalext.of_mpqf (Mpqf.of_string mi)
                  (Mpqf.of_string ma)
            | _ -> failwith "other lengths not allowed"
          in
          Expression (const_expr vm ival, type_of_operand l)
      | false -> Expression (const_expr vm I.top, type_of_operand l))

let load_standard vm mem o t (offset_expl : int32) =
  let mem_min, mem_max = (0l, Memories.Linearmem.length_max mem) in
  let _w, _s =
    match t with
    | Wasm.Types.I32Type | F32Type -> (4, 32)
    | Wasm.Types.I64Type | F64Type -> (8, 64)
  in
  let conv_f b =
    match t with
    | I32Type ->
        Utilities.Conversions.int32_binary_to_decimal b |> Int32.to_string
    | I64Type ->
        Utilities.Conversions.int64_binary_to_decimal b |> Int64.to_string
    | F32Type ->
        Utilities.Conversions.float32_binary_to_decimal b |> Float.to_string
    | F64Type ->
        Utilities.Conversions.float64_binary_to_decimal b |> Float.to_string
  in

  let c = Memories.Operand.concretize vm o in
  printer Format.print_string "IntervalC:";
  printer (Apronext.Intervalext.print Format.std_formatter) c;
  (*range of offset addresses*)
  if not (Apronext.Intervalext.is_bounded c) then
    Expression (const_expr vm Apronext.Intervalext.top, t)
  else if Apronext.Intervalext.is_bottom c then Bottom
  else
    let start_from, start_to =
      I.to_float c |> tappl Int32.of_float |> tappl (Int32.add offset_expl)
    in
    printer (Printf.printf "IntervalC~From:%s;") (Int32.to_string start_from);
    printer (Printf.printf "IntervalC~To:%s;") (Int32.to_string start_to);
    let threshold_mem = 10 in
    let is_past_thresh =
      Apronext.Scalarext.cmp_int (Apronext.Intervalext.range c) threshold_mem
      >= 0
    in
    let _addrs =
      if is_past_thresh then []
      else
        List.init
          (Int32.add (Int32.sub start_to start_from) 1l |> Int32.to_int)
          (fun x -> Int32.add start_from (Int32.of_int x))
        |> List.filter (fun (a : int32) ->
               a >= mem_min && a <= Int32.sub mem_max (Int32.of_int _s))
    in
    printer Format.print_string "\t~ Set of addresses:";
    printer
      (List.iter (fun i -> Format.print_string (Int32.to_string i)))
      _addrs;
    printer Format.print_newline ();
    (*concretized set of addresses to read from (each sublist represents all of the words to read from memory)*)
    (*BUG: stack overflow this one*)
    let addrs_list_set =
      listmap'
        (fun f -> List.init _w (fun x -> Int32.add f (Int32.of_int x)))
        _addrs
    in
    (*word by word reading*)
    let reads =
      listmap'
        (fun addr_list ->
          listmap' (fun a -> Memories.Linearmem.read_byte a mem) addr_list)
        addrs_list_set
    in
    (*readings*)
    let reads' =
      if not is_past_thresh then
        listmap'
          (*memory is little endian, this makes it big endian*)
            (fun r ->
            List.fold_left
              (fun acc v ->
                match v with Some v -> Array.append v acc | None -> acc)
              [||] r)
          reads
      else [ Array.make _s Bitwisealu.Bit.Top ]
    in
    (*bitwise result*)
    if reads' = [] then Bottom
    else
      let read =
        List.fold_left
          (fun r x -> Datastructures.Abstractbyte.join r x)
          (List.nth reads' 0) reads'
      in
      Array.iter (fun b -> printer Bitwisealu.Bit.print b) read;
      let mpqf_of_string' s =
        printer Format.print_string "\n\n~~~~";
        printer Format.print_string s;
        printer Format.print_string "\n\n~~~~";
        if s = "0." then Mpqf.of_int 0 else Mpqf.of_string s
      in
      let lim1, lim2 =
        (*BUG(29 aug-2024): when all top, the values produced are -1;0 (all 1s and all 0s.)
          as_min_max has to work differently to work correctly*)
        Datastructures.Abstractbyte.as_int_arrays ~signed:true read
        |> tappl Array.to_list |> tappl conv_f |> tappl mpqf_of_string'
        |> tappl S.of_mpqf
      in
      let i =
        if S.cmp lim1 lim2 <= 0 then I.of_scalar lim1 lim2
        else I.of_scalar lim2 lim1
      in
      printer Format.print_string "\t~ Loaded:";
      printer (Apronext.Intervalext.print Format.std_formatter) i;
      printer Format.print_string "\n";
      if Apronext.Intervalext.is_bottom i then Bottom
      else Expression (const_expr vm i, t)

let store_standard _vm _mem _addr _val _t (_offset_expl : int32) =
  printer Format.printf "~ Symbolic Operand for Address:";
  printer Memories.Operand.print_operand _addr;
  let addr, val_ = (concretize _vm _addr, concretize _vm _val) in
  printer Format.printf "~ Interval of ADDR to write:";
  printer (Apronext.Intervalext.print Format.str_formatter) addr;
  printer Format.printf "~ Value to write:";
  printer (Apronext.Intervalext.print Format.str_formatter) val_;
  printer Format.print_newline ();
  let _w, _s =
    match _t with
    | Wasm.Types.I32Type | F32Type -> (4, 32)
    | Wasm.Types.I64Type | F64Type -> (8, 64)
  in
  let mem_min, mem_max =
    (0l, Int32.sub (Memories.Linearmem.length_max _mem) (Int32.of_int _s))
  in
  let _bytes_to_split =
    Language.Bitwisenumber.of_interval val_ _t
    |> Language.Bitwisenumber.binary_interval_to_abstract_bitwise
  in

  let _b =
    Array.to_list
      (Datastructures.Abstractbyte.split_in_bytesized_arrays
         _bytes_to_split.val_)
    |> List.rev |> Array.of_list
  in
  (*these bits are to splint in byte-sized (there is instr for that)
    and then reversed in order for endiannes consistency. then they can be written
    type of func to use to write: bit array array -> int -> t -> t*)
  (*range of offset addresses*)
  let threshold_mem = 1000 in
  if
    (not (Apronext.Intervalext.is_bounded addr))
    || Apronext.Scalarext.cmp_int
         (Apronext.Intervalext.range addr)
         threshold_mem
       >= 0
  then Memories.Linearmem.T { min = 0l; max = mem_max }
  else
    let start_from, start_to =
      I.to_float addr |> tappl Int32.of_float |> tappl (Int32.add _offset_expl)
    in

    (*
    let rec topping addr upto memory =
      if addr > upto then memory
      else
        topping (Int32.succ addr) upto
          (Memories.Linearmem.strong_write_to_mem
             [| Datastructures.Abstractbyte.alloc_byte_top |]
             addr memory)
    in
    topping (Int32.max mem_min start_from) mem_max _mem*)
    (*(
      let m' = Array.copy _mem in
      for i = max mem_min start_from to mem_max do
        Array.set mem i Datastructures.Abstractbyte.alloc_byte_top
      done;
      m')*)

    (*concretized range of offset addresses*)
    let _addrs =
      List.init
        (*(min mem_max start_to - max mem_min start_from + 1)*)
        (Int32.add
           (Int32.sub
              (Int32.min mem_max start_to)
              (Int32.max mem_min start_from))
           1l
        |> Int32.to_int)
        (fun x -> Int32.add (Int32.max mem_min start_from) (Int32.of_int x))
    in
    let wf =
      match List.length _addrs with
      | 0 -> raise NoValidWritesExn
      | 1 -> Memories.Linearmem.strong_write_to_mem
      | _ -> Memories.Linearmem.write_to_mem
    in
    let mem' = List.fold_left (fun x _a -> wf _b _a x) _mem _addrs in
    mem'

let memsize vm mem =
  let s = Memories.Linearmem.size mem |> Int32.to_int in
  let ival = I.of_scalar (S.of_int s) (S.of_int s) in
  Expression (const_expr vm ival, I32Type)
