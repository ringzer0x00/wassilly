module I = struct
  include Apronext.Intervalext

  let float_scalar = Apronext.Scalarext.of_float
  let int_scalar = Apronext.Scalarext.of_int
  let inf_scalar = Apronext.Scalarext.of_infty
  let pp = print
end

type wasmType = I32Type | I64Type | F32Type | F64Type [@@deriving show]

type inf = PInf | NInf
and value = Num of I.t | Rel of string
and tabType = Funcref | Externref
and tableBinding = TableBinding of int32 * int32
and unspec = Top | Bot
and param = Param of wasmType * string
and resulttype = ResultType of wasmType
and result = Result of wasmType * value
and funcsig = FuncSig of param list * resulttype list
and callee = Calls of int32
and precond = string

and assignment =
  | GlobAss of int32 * wasmType * value
  | MemAss of string * value (*offset*) * value (*value*) * wasmType
  | TableAss of string * tableBinding

and implies = result list * assignment list * callee list
and impl = Implication of precond list * implies * impl | Implies of implies

and term =
  | Glob of string * wasmType * value
  | Table of string * tabType * tableBinding list * unspec
  | PostInst of assignment list
  | Func of string * funcsig * impl
  | ImportObj of term

and program = Program of term list [@@deriving show]

let concat t p = Program (t :: p)

let dump_program (Program atoms) =
  "[" ^ String.concat ", " (List.map show_term atoms) ^ "]"
