type val_ = Value.value

module Language = struct
  type bop = val_ -> val_ -> val_
  type uop = val_ -> val_
  type fid = string
  type var = string
  type depth = int
  type arity = int

  type stmt = cmd list

  and cmd =
    | Block of arity * stmt
    | Loop of arity * stmt
    | MemRead of var
    | MemWrite of var
    | Val of int32
    | Binop of bop
    | Sub
    | Sum
    | Mul
    | Neg
    | Unop of uop
    | If of arity * stmt * stmt
    | Call of fid
    | Br of depth
    | BrIf of depth


  type t = stmt

  let compare = compare
end

module Funcs = struct
  include Map.Make (String)

  type tt = (string list * Language.t) t
  type t = tt

  let empty : t = empty
end
