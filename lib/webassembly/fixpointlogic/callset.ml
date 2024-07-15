module Edge = struct
  type f = Int32.t
  type t = f * f
  type partial = f -> t

  let compare = compare
  let edge f t : t = (f, t)
  let ( ~> ) = edge
  let partial f : partial = edge f
end

module CallSet = struct
  module S = Set.Make (Edge)

  let phi = S.empty
  let singleton = S.singleton
  let add = S.add
  let union = S.union
  let add_partial s p t = add (p t) s
end

let e = CallSet.add_partial CallSet.phi (Edge.partial Int32.zero) Int32.zero
