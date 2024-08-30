(*
Ref = Exported GlobalVar | Exported Memory (Loc)
Expr = Ref | AVal 
Constr = Expr ∈ AVal | Expr ∉ AVal | Constr And Constr | Constr Or Constr

Res = (Wasm) typed vector
Eff = Effects (calls, modifications to shared - exported AND imported - object such as memory, globals, tables)

PrePost = (Res, Eff) | with (Constr) (Res,Eff) otherwise PrePost
*)

type wasmType
type id
type interval
type ref = GVar of id * wasmType | MemLoc of id * wasmType
type ival = Interval of interval * wasmType

type val_expr = Ref of ref | Aval of ival
type func = Func of wasmType list * wasmType list

type res = val_expr list
type eff

type cond =
  | ElemOf of val_expr * val_expr
  | Not of cond
  | Conj of cond * cond
  | Disj of cond * cond

type pre_post = Res of res * eff | With of cond * res * pre_post

type funcspec = FuncSpec of func * pre_post
type spec = funcspec list
