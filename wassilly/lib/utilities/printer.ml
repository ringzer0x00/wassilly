let print pf o =
  if !Conf.debug then (
    pf o;
    Format.print_flush ())


let print_always pf o =
      pf o;
    Format.print_flush ()