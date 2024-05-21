module type L = Genericcomponents.Language.Language

module ExEnv =
  Genericcomponents.Env.ApronEnv
    (Genericcomponents.Alloc.VarApronAlloc)
    (Genericcomponents.Value.ApronValue)

module Language : L = struct
  type _bexpr = Eq of _expr * _expr

  and _expr =
    | Var of string
    | Num of int
    | Add of _expr * _expr
    | Sub of _expr * _expr
    | Mul of _expr * _expr
    | If of _bexpr * _expr * _expr
    | Call of string * _expr list

  type l = _expr
  type in_ = ExEnv.t * l
  type out_ = ExEnv.value

  let eval (_env, expr) _stack _cache : out_ =
    match expr with
    | Var v -> ExEnv.lookup (ExEnv.alloc_of_string v) _env
    | Add (_l,_r) -> failwith "meaow"
    | _ -> failwith "meaow"
end
