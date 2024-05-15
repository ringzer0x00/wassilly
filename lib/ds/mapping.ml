module type T = sig
  type t
end

module Make (O : Map.OrderedType) (R : T) = struct
  include Map.Make (O)

  type t = R.t Map.Make(O).t
end
