(*
Ref = Exported GlobalVar | Exported Memory (Loc)
Expr = Ref | AVal 
Constr = Expr ∈ AVal | Expr ∉ AVal | Constr And Constr | Constr Or Constr

Res = (Wasm) typed vector
Eff = Effects (calls, modifications to shared - exported AND imported - object such as memory, globals, tables)

PrePost = (Res, Eff) | with (Constr) (Res,Eff) otherwise PrePost



================ re-structure with module instance, otherwise it's a mess!!!

*)

type wasmType
type id
type interval
type param
type ref = GVar of id | MemLoc of int
type ival = Interval of interval * wasmType
type val_expr = Param of param | Aval of ival
type func = Func of wasmType list * wasmType list
type eff = ref * ival
type res = val_expr list * eff

type clause =
  | IsElemOf of val_expr * val_expr (*∈*)
  | Conj of clause * clause
  | Disj of clause * clause

type pre_post = Res of res * eff | With of clause * res * pre_post

(*these are not part of ast/rules and should not be treated as such!!!!!*)
type funcspec = FuncSpec of func * pre_post
type spec = funcspec list
