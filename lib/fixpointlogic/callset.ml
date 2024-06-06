(*todo*)
module Edge = struct
  type f = Int32.t
  type t = f * f

  let compare = compare
  let partial (f : f) : f = f
  let e f t : t = (f, t)
end

module CallSet = struct
  module S = Set.Make (Edge)

  let add = S.add
  let union = S.union
end
