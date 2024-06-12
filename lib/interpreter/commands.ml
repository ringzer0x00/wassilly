module MS = Memories.Frame
module LM = Fixpoint.Labelmap.LabelMap
module MA = Fixpoint.Answer

type ans = MA.t
type module_ = Wasm.Ast.module_ (*or ' (?)*)
type p = Language.Command.Command.t

open Fixpoint
module Cache = Cache.Cache
module Stack = Stack.Stack
module SCG = Scg.SCC
module CallSet = Callset.CallSet

let getfbody (mod_ : module_) idx =
  let funx = List.nth mod_.it.funcs idx in
  (funx.it.body, funx.it.locals, funx.it.ftype)

let (*rec*) fixpoint _module (call, ifb) _cstack stack cache stepf =
  let _ms, _p = call in
  match ifb with
  | false -> stepf _module call _cstack stack cache
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
          | false -> Iterate.iterate _module call _cstack stack cache stepf))

(*eval should not be called recursively*)
let rec step _module call _cstack _sk cache : ans * Cache.t * SCG.t =
  let (ms : MS.t), (p : p) = call in
  match p with
  | [] -> failwith "" (*do labek stack stuff*)
  | h :: _t ->
      let (_res : ans), _cache', _scg =
        (*as opposed to ms this should return a vector of values which is then appended to the ms's operand stack*)
        match h.it with
        | Const num ->
            ( { nat = Alu.const num ms; jmp = LM.bot; ret = MS.Bot },
              cache,
              SCG.empty )
        | Binary bop ->
            ( { nat = Binops.eval_binop bop ms; jmp = LM.bot; ret = MS.Bot },
              cache,
              SCG.empty )
        | Unary uop ->
            ( { nat = Unops.eval_unop uop ms; jmp = LM.bot; ret = MS.Bot },
              cache,
              SCG.empty )
        | Drop ->
            ( { nat = MS.pop_operand ms; jmp = LM.bot; ret = MS.Bot },
              cache,
              SCG.empty )
        | Nop -> ({ nat = ms; jmp = LM.bot; ret = MS.Bot }, cache, SCG.empty)
        | Return ->
            failwith
              "flush labels, get function type and return memorystate with the \
               first n values top of the stack,"
        | Br i -> (
            let idx = i.it |> Int32.to_int in
            let l = MS.peek_nth_label ms idx in
            let ms' : MS.t = MS.pop_n_labels ms (idx + 1) in
            match l with
            | Some (BlockLabel b) ->
                (*check if labelstack is empty, if so it is treated as a return*)
                if not (MS.is_lsk_empty ms') then
                  ( { nat = MS.Bot; jmp = LM.singleton b.cmd ms'; ret = MS.Bot },
                    cache,
                    SCG.empty )
                else
                  ({ nat = MS.Bot; jmp = LM.bot; ret = ms' }, cache, SCG.empty)
            | Some (LoopLabel _l) -> failwith ""
            | None -> failwith "Invalid Br depth"
            (*failwith
                "peek nth label, pop n+1 labels, call fixpoint with present \
              | BrIf _ -> failwith "weird ass instruction"
                state and brcont as program"*))
        | Block (_bt, _is) ->
            let l =
              Memories.Labelstack.block
                { natcont = _t; brcont = _t; typ = _bt; cmd = [ h ] }
            in
            let ms' = Cflow.enter_label l ms in
            fixpoint _module ((ms', _is), false) _cstack _sk cache step
        | Loop (_bt, _is) ->
            let _lab =
              Memories.Labelstack.loop
                { natcont = _t; brcont = h :: _t; typ = _bt; cmd = [ h ] }
            in
            let ms' = Cflow.enter_label _lab ms in
            fixpoint _module ((ms', _is), true) _cstack _sk cache step
        | If (_blocktype, _then, _else) ->
            let l =
              Memories.Labelstack.block
                { natcont = _t; brcont = _t; typ = _blocktype; cmd = [ h ] }
            in
            let ms' = Cflow.enter_label l ms in
            let ms_t, ms_f = Cflow.ite_condition ms' in
            (*check for bottoms before calling fix*)
            let a_true, c', _scgt =
              fixpoint _module ((ms_t, _then), false) _cstack _sk cache step
            in
            let a_false, c'', _scgf =
              fixpoint _module ((ms_f, _else), false) _cstack _sk c' step
            in
            let a, scg = (MA.lub a_true a_false, SCG.union _scgt _scgf) in
            (a, c'', scg)
        | Call _i ->
            failwith "call to fixpoint"
            (*before evaluating call push present natcont and other info to callstack*)
        | _ -> failwith "other commands"
      in
      (_res, _cache', _scg)
(*failwith "fixpoint _module ((_ms', t), false) _cstack _sk cache' eval"*)
