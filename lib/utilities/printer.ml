let print pf o =
  if !Conf.debug then (
    Format.print_flush ();
    pf o)
