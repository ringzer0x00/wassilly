module type O = Inputoutput.InterpreterOutput

module type CD = sig
  type d
  type t

  val compare : t -> t -> int
  val unstabledata : d -> t
  val stabledata : d -> t
end

module CachedData (O : O) : CD = struct
  type stability = Stable | Unstable
  type d = O.t
  type t = d * stability

  let compare = compare
  let unstabledata d : t = (d, Unstable)
  let stabledata d : t = (d, Stable)
end
