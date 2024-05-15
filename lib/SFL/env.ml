module type E = Genericcomponents.Env.GE

module SFLEnv : E = struct
  type value
  type alloc
  type t

  let make = failwith ""
  let add _ _ _ = failwith ""
  let lookup _ _ = failwith ""
  (*let lub _ _ = failwith ""
    let widen _ _ = failwith ""*)
end
