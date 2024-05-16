module type E = Genericcomponents.Env.GE

module SFLEnv : E =
  Genericcomponents.Env.ApronEnv (Genericcomponents.Alloc.VarApronAlloc)
