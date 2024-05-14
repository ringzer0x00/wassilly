module type GI = Genericcomponents.Inputoutput.InterpreterInput (*env,expr*)

module SFLInput : GI = struct
  type env
  type expr = Language.Command.t
  type t = env * expr

  let compare = compare
  let pred (e : t) (i : t) = snd e = snd i
  (*  let in_domain elem stack = S.exists (I.pred elem) stack*)
end
