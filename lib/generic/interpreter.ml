module type II = Inputoutput.InterpreterInput (*env)(expr*)
module type IO = Inputoutput.InterpreterOutput (*val*)
module type Sk = Stack.S
module type Ca = Cache.C
module type SCG = Scg.SCG

module type FP = sig
  type in_
  type out
  type sk
  type ca
  type scg

  val fixpoint : in_ -> sk -> ca -> out * ca * scg
end

module type GI = sig
  type in_
  type out
  type sk
  type ca
  type scg

  val fix : in_ -> sk -> ca -> out * ca * scg

  val eval :
    (in_ -> sk -> ca -> out * ca * scg) -> in_ -> sk -> ca -> out * ca * scg
end

module Fixpoint (I : II) (O : IO) (S : Sk) (C : Ca) (SCG : SCG) : FP = struct
  type in_ = I.t
  type out = O.t
  type sk = S.t
  type ca = C.t
  type scg = SCG.t

  let fixpoint _input _stack _cache = failwith "todo"
end

module Interpreter (Fix : FP) (I : II) (O : IO) (S : Sk) (C : Ca) (SCG : SCG) :
  GI = struct
  type in_ = Fix.in_
  type out = Fix.out
  type sk = Fix.sk
  type ca = Fix.ca
  type scg = Fix.scg

  let fix = Fix.fixpoint

  let eval _fixpoint (_input : in_) (_stack : sk) (_cache : ca) : out * ca * scg
      =
    failwith "must be defined on target language"
end

