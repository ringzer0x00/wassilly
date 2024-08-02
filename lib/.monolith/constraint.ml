open Command.Language

type b = bexpr

let might_be_true mgr (_env : 'a Apron.Abstract1.t) _cond =
  let _l, _r =
    match _cond with
    | Eq (lft, right) ->
        let l = match lft with Var v -> v | _ -> failwith "mono" in
        let r = match right with Num n -> n | _ -> failwith "mono" in
        (l, r)
  in
  let cons_true =
    Apron.Parser.texpr1_of_string _env.env (_l ^ "-" ^ Int.to_string _r)
  in
  Apron.Abstract1.bound_texpr mgr _env cons_true

let texpr_of_boolequality (_env : 'a Apron.Abstract1.t) _cond =
  let _l, _r =
    match _cond with
    | Eq (lft, right) ->
        let l = match lft with Var v -> v | _ -> failwith "mono" in
        let r = match right with Num n -> n | _ -> failwith "mono" in
        (l, r)
  in
  Apron.Parser.texpr1_of_string _env.env (_l ^ "-" ^ Int.to_string _r)

let bexpr_as_tcons (_env : 'a Apron.Abstract1.t) (_cond : b) =
  let t = texpr_of_boolequality _env _cond in
  let cons_true, cons_false =
    (Apron.Tcons1.make t Apron.Tcons1.EQ, Apron.Tcons1.make t Apron.Tcons1.DISEQ)
  in
  (cons_true, cons_false)

let filter mgr (env : 'a Apron.Abstract1.t) cons =
  Format.print_string "Filter: boolean constrain: \n";
  Apron.Abstract1.print Format.std_formatter env;
  Apron.Tcons1.print Format.std_formatter cons;

  let cons_earray = Apron.Tcons1.array_make env.env 1 in
  Apron.Tcons1.array_set cons_earray 0 cons;
  let r = Apron.Abstract1.meet_tcons_array mgr env cons_earray in
  Format.print_string "Filter result: \n";
  Apron.Abstract1.print Format.std_formatter r;
  Format.print_string "\n";

  r
