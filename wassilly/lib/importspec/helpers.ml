let getfuncspec = function
  | Term.Func (n, s, t) -> (n, s, t)
  | _ -> failwith "getfuncspec @ helpers. not func"
