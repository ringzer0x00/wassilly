module type AST = sig
  type _bexpr
  type _expr
  type l
end

module type C = sig
  type t
  val compare : t -> t -> int
end

module Command (L : AST) : C = struct
  type t = L.l

  let compare = compare
end
