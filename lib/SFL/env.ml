module type E = Genericcomponents.Env.GE

module SFLEnv =
  Genericcomponents.Env.ApronEnv
    (Genericcomponents.Alloc.VarApronAlloc)
    (Value.SFLVal)
