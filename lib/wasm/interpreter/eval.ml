open Datastructures.Monad
module MS = Memories.Frame
module LM = Fixpoint.Labelmap.LabelMap
module MA = Fixpoint.Answer

type ans = MA.res Datastructures.Monad.t
type module_ = Wasm.Ast.module_ (*or ' (?)*)
type p = Language.Command.Command.t

open Fixpoint
module Cache = Cache.Cache
module Stack = Stack.Stack
module SCG = Scg.SCC
module CallSet = Callset.CallSet

let cmd_result = Cflow.simplecmd_answer
let seq_result = Cflow.seq_answer
let pans_of_answer = MA.pans_of_answer

let getfbody (mod_ : module_) idx =
  let funx = List.nth mod_.it.funcs idx in
  (funx.it.body, funx.it.locals, funx.it.ftype)

let fixpoint _module (call, ifb) _cstack stack cache pres stepf =
  let _ms, _p = call in
  match ifb with
  | false -> stepf _module call _cstack stack cache pres
  | true -> (
      match Cache.call_in_cache call cache with
      | Some cached -> (
          let stable, resCached = cached in
          match stable with
          | Cache.Stable -> (resCached, cache, SCG.empty)
          | Cache.Unstable -> (resCached, cache, SCG.singleton call))
      | None -> (
          match Stack.call_in_stack call stack with
          | true -> (MA.bot, cache, SCG.singleton call)
          | false -> Iterate.iterate _module call _cstack stack cache pres stepf
          ))

(*eval should not be called recursively*)
let rec step modul_ call cstack sk cache p_ans : ans * Cache.t * SCG.t =
  let (ms : MS.t), (p : p) = call in

  match p with
  | [] -> (cmd_result (Instructions.end_of_block ms) p_ans, cache, SCG.empty)
  | c1 :: c2 ->
      let (res1 : ans), cache', scg_h =
        (*as opposed to ms this should return a vector of values which is then appended to the ms's operand stack*)
        match c1.it with
        | Const num ->
            (cmd_result (Instructions.const_val num ms) p_ans, cache, SCG.empty)
        | Binary bop ->
            (cmd_result (Binops.eval_binop bop ms) p_ans, cache, SCG.empty)
        | Unary uop ->
            (cmd_result (Unops.eval_unop uop ms) p_ans, cache, SCG.empty)
        | Drop -> (cmd_result (MS.pop_operand ms) p_ans, cache, SCG.empty)
        | Nop -> (cmd_result ms p_ans, cache, SCG.empty)
        | Return ->
            failwith
              "flush labels, get function type and return memorystate with the \
               first n values top of the stack,"
        | Br i -> (
            (*check this br, its probably wrong*)
            let idx = i.it |> Int32.to_int in
            let l = MS.peek_nth_label ms idx in
            let ms' : MS.t = MS.pop_n_labels ms (idx + 1) in
            match l with
            | Some (BlockLabel b) ->
                ( Def
                    {
                      nat = MS.Bot;
                      br = LM.add_raw b.cmd ms' p_ans.p_br;
                      return = p_ans.p_return;
                    },
                  cache,
                  SCG.empty )
            | Some (LoopLabel _l) -> failwith ""
            | None ->
                (*return-like case*)
                ( Def
                    {
                      nat = MS.Bot;
                      br = p_ans.p_br;
                      return = MS.join p_ans.p_return ms';
                    },
                  cache,
                  SCG.empty )
            (*failwith
                "peek nth label, pop n+1 labels, call fixpoint with present \

                state and brcont as program"*))
        | BrIf _ -> failwith "weird ass instruction"
        | Block (_bt, bbody) ->
            let l =
              Memories.Labelstack.block
                { natcont = c2; brcont = c2; typ = _bt; cmd = [ c1 ] }
            in
            let ms' = Cflow.enter_label l ms in
            let a, c, g =
              fixpoint modul_ ((ms', bbody), false) cstack sk cache p_ans step
            in
            (Cflow.block_result a [ c1 ], c, g)
        | Loop (_bt, lbody) ->
            let _lab =
              Memories.Labelstack.loop
                { natcont = c2; brcont = c1 :: c2; typ = _bt; cmd = [ c1 ] }
            in
            let ms' = Cflow.enter_label _lab ms in
            let a, c, g =
              fixpoint modul_ ((ms', lbody), true) cstack sk cache p_ans step
            in
            (Cflow.block_result a [ c1 ], c, g)
        | If (_blocktype, _then, _else) ->
            let _rewritten : Wasm.Ast.instr =
              { it = Wasm.Ast.Block (_blocktype, _then); at = c1.at }
            in
            let l =
              Memories.Labelstack.block
                { natcont = c2; brcont = c2; typ = _blocktype; cmd = [ c1 ] }
            in
            let ms' = Cflow.enter_label l ms in
            let ms_t, ms_f = Cflow.ite_condition ms' in
            (*check for bottoms before calling fix*)
            let a_true, c', _scgt =
              fixpoint modul_ ((ms_t, _then), false) cstack sk cache p_ans step
            in
            let a_true = Cflow.block_result a_true [ c1 ] in
            let a_false, c'', _scgf =
              fixpoint modul_ ((ms_f, _else), false) cstack sk c' p_ans step
            in
            let a_false = Cflow.block_result a_false [ c1 ] in
            let a, scg = (MA.lub a_true a_false, SCG.union _scgt _scgf) in
            (a, c'', scg)
        | Call _i ->
            failwith "call to fixpoint"
            (*before evaluating call push present natcont and other info to callstack*)
        | _ -> failwith "other commands"
      in
      let res2, cache'', scg_t =
        Cflow.monad_step res1 cache' (fun x ->
            fixpoint modul_
              ((x.nat, c2), false)
              cstack sk cache' (pans_of_answer x) step)
      in
      (seq_result res1 res2, cache'', SCG.union scg_h scg_t)
