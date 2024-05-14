module type I = Inputoutput.InterpreterInput
module type O = Inputoutput.InterpreterOutput
module type C = Cache.C
module type S = Stack.S
module type G = Scg.SCG

module type INfix = sig
  type input
  type stack
  type cache
  type t = input -> stack -> cache
end

module type OUTfix = sig
  type cache
  type scg
  type output
  type t = cache -> scg -> output
end

module Fixpoint (I : INfix) (O : OUTfix) = struct
  type comp = I.t -> O.t
end
