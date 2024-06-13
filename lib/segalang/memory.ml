open Aprond

module Memory = struct
  type t = Polka.strict Apron.Abstract1.t

  let makemgr m = Aprond.new_mgr m

  let make_empty mgr =
    let aenv = new_aenv [||] [||] in
    let ad = new_memory mgr aenv in
    ad

  let make integers reals mgr =
    let integers = List.map (fun v -> Apron.Var.of_string v) integers in
    let reals = List.map (fun v -> Apron.Var.of_string v) reals in

    let aenv = new_aenv (Array.of_list integers) (Array.of_list reals) in
    let ad = new_memory mgr aenv in
    ad

  let join mgr m1 m2 = Aprond.join mgr m1 m2
  let print m = Apron.Abstract1.print Format.std_formatter m
  let compare = compare
  let included mgr m1 m2 = Apron.Abstract1.is_leq mgr m1 m2

  let widen mgr m1 m2 =
    Format.print_string "Widen fst:";
    print m1;
    Format.print_string "\nsnd:";
    print m2;
    let r1 = Aprond.widening mgr m1 m2 in
    let r2 = Aprond.widening mgr m2 m1 in
    let r = join mgr r1 r2 in
    Format.print_string "result:";
    print r;
    r

  let find mgr var ad =
    Apron.Abstract1.bound_variable mgr ad (Apron.Var.of_string var)

  let add _mgr _varname _val (_env : t) =
    let av = Apron.Var.of_string _varname in
    let aenv' = Apron.Environment.add _env.env [| av |] [||] in
    let env' = Apron.Abstract1.change_environment _mgr _env aenv' true in
    let expr = Value.to_expr env'.env _val in
    Format.print_string ("assign: " ^ _varname ^ ":=");
    Apron.Texpr1.print Format.std_formatter expr;
    Apron.Abstract1.assign_texpr _mgr env' av expr None
end
