open Apronext

module type ApronD = sig
  type dt
  type t
  type env
  type varid
  type vartype

  val top : env -> t
  val bottom : env -> t
  val lub : t -> t -> t
  val meet : t -> t -> t
  val widen : t -> t -> t
  val makeEnv : varid array -> varid array -> env
  val addVar : t -> vartype -> varid -> t
  val addVarString : t -> vartype -> string -> t
  val envLub : env -> env -> env
  val envMeet : env -> env -> env
  val mgr : dt Apron.Manager.t
  val partialOrder : t -> t -> bool
  val toString : t -> string
  val print : t -> unit
end

module ApronLattice (D : ApronD) : Latticewithvariables.LV = struct
  type dt = D.dt
  type t = D.t
  type env = D.env
  type man = dt Apron.Manager.t
  type vartype = D.vartype
  type varid = D.varid

  let mgr = D.mgr
  let top = D.top
  let bottom = D.bottom
  let isTop _ _ = failwith ""
  let isBottom _ _ = failwith ""
  let lub = D.lub
  let meet = D.meet
  let widen = D.widen
  let makeEnv = D.makeEnv
  let addVar = D.addVar
  let addVarString = D.addVarString
  let envLub = D.envLub
  let envMeet = D.envMeet
  let partialOrder = D.partialOrder
  let toString = D.toString
  let print = D.print
end

module StrictPoly : ApronD = struct
  module PT = Apol

  type dt = Polka.strict Polka.t
  type t = PT.t
  type env = PT.E.t
  type varid = Apron.Var.t
  type vartype = PT.E.typvar

  let mgr = PT.man
  let top env = PT.top env
  let bottom env = PT.bottom env
  let lub b1 b2 = PT.join b1 b2
  let widen b1 b2 = PT.widening b1 b2
  let meet b1 b2 = PT.meet b1 b2
  let makeEnv i r = PT.E.make i r
  let addVar abs vt vid = PT.add_var abs vt vid
  let addVarString abs vt vstr = PT.add_var_s abs vt vstr
  let envLub e1 e2 = PT.E.join e1 e2
  let envMeet e1 e2 = PT.E.lce e1 e2
  let partialOrder b1 b2 = PT.is_leq b1 b2
  let toString _ = failwith "no tostring"
  let print x = PT.print Format.std_formatter x
end

(*
module Octagons : ApronD = struct
  module PT = Aoct

  type dt = Oct.t
  type t = PT.t
  type env = PT.E.t
  type varid = Apron.Var.t
  type vartype = PT.E.typvar

  let mgr = PT.man
  let top env = PT.top env
  let bottom env = PT.bottom env
  let makeEnv i r = PT.E.make i r
  let addVar abs vt vid = PT.add_var abs vt vid
  let addVarString abs vt vstr = PT.add_var_s abs vt vstr
  let envLub e1 e2 = PT.E.join e1 e2
  let envMeet e1 e2 = PT.E.lce e1 e2
end

module Box : ApronD = struct
  module PT = Apol

  type dt = Box.t
  type t = PT.t
  type env = PT.E.t
  type varid = Apron.Var.t
  type vartype = PT.E.typvar

  let mgr = PT.man
  let top env = PT.top env
  let bottom env = PT.bottom env
  let makeEnv i r = PT.E.make i r
  let addVar abs vt vid = PT.add_var abs vt vid
  let addVarString abs vt vstr = PT.add_var_s abs vt vstr
  let envLub e1 e2 = PT.E.join e1 e2
  let envMeet e1 e2 = PT.E.lce e1 e2
end
*)
module StrictPolyLattice = ApronLattice (StrictPoly)

(*module OctagonLattice = ApronLattice (Octagons)
  module BoxLattice = ApronLattice (Box)
*)
let _test = StrictPolyLattice.addVar
