let sum mgr _lval _rval _env =
  let v =
    Apron.Abstract1.bound_texpr mgr _env
      (Apron.Texpr1.binop Apron.Texpr1.Add
         (Value.to_expr _env.env _lval)
         (Value.to_expr _env.env _rval)
         Apron.Texpr1.Int Apron.Texpr1.Zero)
  in
  Value.print _lval;
  Format.print_string "+";
  Value.print _rval;
  Format.print_string "=";
  Value.print v;
  v

let sub mgr _lval _rval _env =
  Apron.Abstract1.bound_texpr mgr _env
    (Apron.Texpr1.binop Apron.Texpr1.Sub
       (Value.to_expr _env.env _lval)
       (Value.to_expr _env.env _rval)
       Apron.Texpr1.Int Apron.Texpr1.Zero)

let mul mgr _lval _rval _env =
  Apron.Abstract1.bound_texpr mgr _env
    (Apron.Texpr1.binop Apron.Texpr1.Mul
       (Value.to_expr _env.env _lval)
       (Value.to_expr _env.env _rval)
       Apron.Texpr1.Int Apron.Texpr1.Zero)
