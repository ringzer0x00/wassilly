module type LV = sig
  include Baselattice.L

  type vartype
  type varid

end
