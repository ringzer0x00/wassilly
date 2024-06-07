module MS = Memories.Frame

type ans = { nat : MS.t; back : MS.t; forw : MS.t }
type module_ = Wasm.Ast.module_ (*or ' (?)*)
type p = Wasm.Ast.instr list

open Fixpoint
module Cache = Cache.Cache
module Stack = Stack.Stack
module SCG = Scg.SCC
module CallSet = Callset.CallSet

let getfbody (mod_ : module_) idx =
  let funx = List.nth mod_.it.funcs idx in
  (funx.it.body, funx.it.locals, funx.it.ftype)

let (*rec*) fixpoint _module (call, ifb) _cstack stack cache evalf =
  let _ms, _p = call in
  match ifb with
  | false -> evalf _module call _cstack stack cache
  | true -> (
      match Cache.call_in_cache call cache with
      | Some cached -> (
          let stable, valCached = cached in
          match stable with
          | Cache.Stable -> (valCached, cache, SCG.empty)
          | Cache.Unstable -> (valCached, cache, SCG.singleton call))
      | None -> (
          match Stack.call_in_stack call stack with
          | true -> (MS.bot, cache, SCG.singleton call)
          | false -> Iterate.iterate _module call _cstack stack cache evalf))

(*cache needs to be mapped to ans too!!!
             *)
let (*rec*) eval _module call _cstack _sk cache : ans * 'a Cache.t * SCG.t =
  let (ms : MS.t), (p : p) = call in
  match p with
  | [] -> failwith "" (*do labek stack stuff*)
  | h :: _t ->
      let _res, _cache', _scg =
        (*as opposed to ms this should return a vector of values which is then appended to the ms's operand stack*)
        match h.it with
        | Const num ->
            ( { nat = Alu.const num ms; back = MS.Bot; forw = MS.Bot },
              cache,
              SCG.empty )
        | Binary bop ->
            ( { nat = Binops.eval_binop bop ms; back = MS.Bot; forw = MS.Bot },
              cache,
              SCG.empty )
        | Unary uop ->
            ( { nat = Unops.eval_unop uop ms; back = MS.Bot; forw = MS.Bot },
              cache,
              SCG.empty )
        | Drop ->
            ( { nat = MS.pop_operand ms; back = MS.Bot; forw = MS.Bot },
              cache,
              SCG.empty )
        | Nop -> ({ nat = ms; back = MS.Bot; forw = MS.Bot }, cache, SCG.empty)
        | If (_blocktype, _then, _else) -> failwith "ite - lub dei result"
        | Call _i ->
            failwith "call to fixpoint"
            (*before evaluating call push present natcont and other info to callstack*)
        | _ -> failwith "other commands"
      in
      failwith "fixpoint _module ((_ms', t), false) _cstack _sk cache' eval"
