let print pf o =
  if !Conf.debug then (
    pf o;
    Format.print_flush ())
