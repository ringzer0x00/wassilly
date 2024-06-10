module MS = Memories.Frame
module MA = Fixpoint.Answer

type ans = MA.t
type module_ = Wasm.Ast.module_ (*or ' (?)*)
type p = Fixpoint.Command.Command.t

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
          | true -> (MA.bot, cache, SCG.singleton call)
          | false -> Iterate.iterate _module call _cstack stack cache evalf))

(*eval should not be called recursively*)
let rec eval _module call _cstack _sk cache : ans * Cache.t * SCG.t =
  let (ms : MS.t), (p : p) = call in
  match p with
  | [] -> failwith "" (*do labek stack stuff*)
  | h :: _t ->
      let (_res : ans), _cache', _scg =
        (*as opposed to ms this should return a vector of values which is then appended to the ms's operand stack*)
        match h.it with
        | Const num ->
            ( { nat = Alu.const num ms; jmp = MS.Bot; ret = MS.Bot },
              cache,
              SCG.empty )
        | Binary bop ->
            ( { nat = Binops.eval_binop bop ms; jmp = MS.Bot; ret = MS.Bot },
              cache,
              SCG.empty )
        | Unary uop ->
            ( { nat = Unops.eval_unop uop ms; jmp = MS.Bot; ret = MS.Bot },
              cache,
              SCG.empty )
        | Drop ->
            ( { nat = MS.pop_operand ms; jmp = MS.Bot; ret = MS.Bot },
              cache,
              SCG.empty )
        | Nop -> ({ nat = ms; jmp = MS.Bot; ret = MS.Bot }, cache, SCG.empty)
        | Block (_bt, _is) ->
            failwith "push label to stack, call fixpoint (ifb true)"
        | Loop (_bt, _is) ->
            failwith "push label to stack, call fixpoint, (ifb false)"
        | If (_blocktype, _then, _else) ->
            (*
           
            INCORRECT, IF BLOCKS SHOULD BE EVALUED LIKE BLOCKS ARE, SO A LABEL SHOULD BE PUSHED INTO THE STACK, BUT FOR NOW ITLL DO
        
        *)
            let ms_t, ms_f = Cflow.ite_condition ms in
            let _r_t, _c', _scgt =
              fixpoint _module ((ms_t, _then), false) _cstack _sk cache eval
            in
            let _r_e, _c'', _scgf =
              fixpoint _module ((ms_f, _else), false) _cstack _sk _c' eval
            in
            let _r, _scg = (MA.lub _r_t _r_e, SCG.union _scgt _scgf) in
            (_r, _c'', _scg)
        | Call _i ->
            failwith "call to fixpoint"
            (*before evaluating call push present natcont and other info to callstack*)
        | _ -> failwith "other commands"
      in
      (_res, _cache', _scg)
(*failwith "fixpoint _module ((_ms', t), false) _cstack _sk cache' eval"*)
