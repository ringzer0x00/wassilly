module type GI = Genericcomponents.Inputoutput.InterpreterOutput (*val*)

module SFLOutput : GI = struct
  type value
  type t = value (*interval*)

  let compare = compare
end
