module type L = Genericcomponents.Language.Language

module Env = Env.SFLEnv

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
  type in_ = Env.t * l
  type out_ = Env.value

  let eval (_env, expr) _stack _cache : out_ =
    match expr with
    | Var v -> Env.lookup (Env.alloc_of_string v) _env
    | Add (_l, _r) -> failwith "meaow"
    | _ -> failwith "meaow"
end

module Out = Genericcomponents.Value.ApronValue
module CD = Cacheddata.CD (Out)
module Cache = Cache.Cache (Cacheddata.CD (Out))

(*env is defined*)