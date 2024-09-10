open Apronext

module type ApronD = sig
  type dt
  type t
  type env
  type varid
  type vartype

  val makeEnv : varid array -> varid array -> env
  val addVar : t -> vartype -> varid -> t
  val addVarString : t -> vartype -> string -> t
  val envLub : env -> env -> env
  val envMeet : env -> env -> env
  val mgr : dt Apron.Manager.t
end

module ApronLattice (D : ApronD) : Latticewithvariables.LV = struct
  open Abstractext

  type t = D.dt Abstractext.t
  type env = Environmentext.t
  type man = D.dt Apron.Manager.t
  type vartype = D.vartype
  type varid = D.varid

  let mgr = D.mgr
  let top env = top mgr env
  let bottom env = bottom mgr env
  let isTop _ _ = failwith ""
  let isBottom _ _ = failwith ""
  let lub b1 b2 = join mgr b1 b2
  let widen b1 b2 = widening mgr b1 b2
  let meet b1 b2 = meet mgr b1 b2

  (**[Aux] operations**)
  let partialOrder b1 b2 = is_leq mgr b1 b2

  let toString _ = failwith "no tostring"
  let print x = print Format.std_formatter x
end

module StrictPoly : ApronD = struct
  module PT = Apol

  type dt = Polka.strict Polka.t
  type t = PT.t
  type env = PT.E.t
  type varid = Apron.Var.t
  type vartype = PT.E.typvar

  let mgr = PT.man
  let makeEnv i r = PT.E.make i r
  let addVar abs vt vid = PT.add_var abs vt vid
  let addVarString abs vt vstr = PT.add_var_s abs vt vstr
  let envLub e1 e2 = PT.E.join e1 e2
  let envMeet e1 e2 = PT.E.lce e1 e2
end

module Octagons : ApronD = struct
  module PT = Aoct

  type dt = Oct.t
  type t = PT.t
  type env = PT.E.t
  type varid = Apron.Var.t
  type vartype = PT.E.typvar

  let mgr = PT.man
  let makeEnv i r = PT.E.make i r
  let addVar abs vt vid = PT.add_var abs vt vid
  let addVarString abs vt vstr = PT.add_var_s abs vt vstr
  let envLub e1 e2 = PT.E.join e1 e2
  let envMeet e1 e2 = PT.E.lce e1 e2
end

module Box : ApronD = struct
  module PT = Abox

  type dt = Box.t
  type t = PT.t
  type env = PT.E.t
  type varid = Apron.Var.t
  type vartype = PT.E.typvar

  let mgr = PT.man
  let makeEnv i r = PT.E.make i r
  let addVar abs vt vid = PT.add_var abs vt vid
  let addVarString abs vt vstr = PT.add_var_s abs vt vstr
  let envLub e1 e2 = PT.E.join e1 e2
  let envMeet e1 e2 = PT.E.lce e1 e2
end

module StrictPolyLattice = ApronLattice (StrictPoly)
module OctagonLattice = ApronLattice (Octagons)
module BoxLattice = ApronLattice (Box)
