open Apronext

module type ApronD = sig
  type dt
  type t
  type env

  val mgr : dt Apron.Manager.t
end

module ApronLattice (D : ApronD) : Lattice.L = struct
  open Abstractext

  type t = D.dt Abstractext.t
  type env = Environmentext.t
  type man = D.dt Apron.Manager.t

  let mgr = D.mgr
  let top env = top mgr env
  let bottom env = bottom mgr env
  let lub b1 b2 = join mgr b1 b2
  let widen b1 b2 = widening mgr b1 b2
  let meet b1 b2 = meet mgr b1 b2

  (**[Aux] operations**)
  let partialOrder b1 b2 = is_leq mgr b1 b2

  let toString _ = failwith "no tostring"
  let print x = print Format.std_formatter x
end

module StrictPoly : ApronD = struct
  type dt = Polka.strict Polka.t
  type t = Apol.t
  type env = Environmentext.t

  let mgr = Apol.man
end

module Octagons : ApronD = struct
  type dt = Oct.t
  type t = Aoct.t
  type env = Environmentext.t

  let mgr = Aoct.man
end

module Box : ApronD = struct
  type dt = Box.t
  type t = Abox.t
  type env = Abox.E.t

  let mgr = Abox.man
end

module StrictPolyLattice = ApronLattice (StrictPoly)
module OctagonLattice = ApronLattice (Octagons)
module BoxLattice = ApronLattice (Box)
