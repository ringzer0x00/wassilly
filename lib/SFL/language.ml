module type L = Genericcomponents.Language.AST

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
end

module C = Genericcomponents.Language.Command
module Command = C (Language)
