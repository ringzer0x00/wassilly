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
let func_ans = Cflow.func_answer
let pans_of_answer = MA.pans_of_answer
let end_of_func = Cflow.end_of_func

let getfbody (mod_ : module_) idx =
  let funx = List.nth mod_.it.funcs idx in
  (funx.it.body, funx.it.locals, funx.it.ftype)

let gettype (mod_ : module_) idx =
  let t = List.nth mod_.it.types idx in
  t.it

let fixpoint _module (call, ifb) stack cache pres stepf =
  let _ms, _p = call in
  match ifb with
  | false -> stepf _module call stack cache pres
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
          | false -> Iterate.iterate _module call stack cache pres stepf))

(*eval should not be called recursively*)
let rec step modul_ call sk cache p_ans : ans * Cache.t * SCG.t =
  let (ms : MS.t), (p : p) = call in
  match ms with
  | Bot -> (Bot, cache, SCG.empty)
  | Def _ -> (
      match p with
      | [] ->
          ( (if MS.is_lsk_empty ms then end_of_func ms p_ans
             else cmd_result (Instructions.end_of_block ms) p_ans),
            cache,
            SCG.empty )
      | c1 :: c2 ->
          let (res1 : ans), cache', scg_h =
            (*as opposed to ms this should return a vector of values which is then appended to the ms's operand stack*)
            match c1.it with
            | LocalSet var ->
                (*rewrite monadic*)
                let val_, ms' =
                  (MS.peek_operand ms |> List.hd, MS.pop_operand ms)
                in
                let b = MS.get_var_binding ms' Loc var.it in
                let ms' = MS.assign_var ms' Loc b val_ in
                (cmd_result ms' p_ans, cache, SCG.empty)
            | GlobalSet var ->
                (*rewrite monadic*)
                let val_, ms' =
                  (MS.peek_operand ms |> List.hd, MS.pop_operand ms)
                in
                let b = MS.get_var_binding ms' Glob var.it in
                let ms' = MS.assign_var ms' Glob b val_ in
                (cmd_result ms' p_ans, cache, SCG.empty)
            | LocalGet _var ->
                (*rewrite monadic*)
                let () =
                  match ms with
                  | Bot -> failwith "lget bot"
                  | Def d ->
                      Printf.printf "LocalGel_bindings: %i"
                        (Memories.Variablemem.VariableMem.M.bindings d.var.loc
                        |> List.length)
                in
                let _b = MS.get_var_binding ms Loc _var.it in
                let _ref = Memories.Operandstack.ref_of_binding _b Loc in
                (cmd_result (Instructions.read ms _ref) p_ans, cache, SCG.empty)
            | GlobalGet _var ->
                (*rewrite monadic*)
                let _b = MS.get_var_binding ms Glob _var.it in
                let _ref = Memories.Operandstack.ref_of_binding _b Glob in
                (cmd_result (Instructions.read ms _ref) p_ans, cache, SCG.empty)
            | Const num ->
                ( cmd_result (Instructions.const_val num ms) p_ans,
                  cache,
                  SCG.empty )
            | Binary bop ->
                (cmd_result (Ops.eval_binop bop ms) p_ans, cache, SCG.empty)
            | Unary uop ->
                (cmd_result (Ops.eval_unop uop ms) p_ans, cache, SCG.empty)
            | Drop -> (cmd_result (MS.pop_operand ms) p_ans, cache, SCG.empty)
            | Nop -> (cmd_result ms p_ans, cache, SCG.empty)
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
                | Some (LoopLabel l) ->
                    fixpoint modul_ ((ms', l.brcont), true) sk cache p_ans step
                | None ->
                    (*return-like case*)
                    ( Def
                        {
                          nat = MS.Bot;
                          br = p_ans.p_br;
                          return = MS.join p_ans.p_return ms';
                        },
                      cache,
                      SCG.empty ))
            | Block (_bt, bbody) ->
                let l =
                  Memories.Labelstack.block
                    { natcont = c2; brcont = c2; typ = _bt; cmd = [ c1 ] }
                in
                let ms' = Cflow.enter_label l ms in
                let a, c, g =
                  fixpoint modul_ ((ms', bbody), false) sk cache p_ans step
                in
                (Cflow.block_result a [ c1 ], c, g)
            | Loop (_bt, lbody) ->
                let _lab =
                  Memories.Labelstack.loop
                    { natcont = c2; brcont = c1 :: c2; typ = _bt; cmd = [ c1 ] }
                in
                let ms' = Cflow.enter_label _lab ms in
                let a, c, g =
                  fixpoint modul_ ((ms', lbody), true) sk cache p_ans step
                in
                (Cflow.block_result a [ c1 ], c, g)
            | If (_blocktype, _then, _else) ->
                let l =
                  Memories.Labelstack.block
                    {
                      natcont = c2;
                      brcont = c2;
                      typ = _blocktype;
                      cmd = [ c1 ];
                    }
                in
                let ms' = Cflow.enter_label l ms in
                let ms_t, ms_f = Cflow.ite_condition ms' in
                let a_true, c', _scgt =
                  fixpoint modul_ ((ms_t, _then), false) sk cache p_ans step
                in
                let a_true = Cflow.block_result a_true [ c1 ] in
                let a_false, c'', _scgf =
                  fixpoint modul_ ((ms_f, _else), false) sk c' p_ans step
                in
                let a_false = Cflow.block_result a_false [ c1 ] in
                let a, scg = (MA.lub a_true a_false, SCG.union _scgt _scgf) in
                (a, c'', scg)
            | BrIf _ -> failwith "weird ass instruction"
            | Return ->
                failwith
                  "write on res.return, set nat to bottom, empty label stack"
            | Call _i ->
                (*## locs is the list of locals declared in the scope of this function,
                  params occupy the first n indices in the input type  (fuzzy words, but
                  if the input type is i32, i32, the first two locals will be the parameters.)
                    params :  (func (param i32) (param f32) (local f64)
                                local.get 0
                                local.get 1
                                local.get 2)
                *)
                let funbody, locs, typ_idx =
                  getfbody modul_ (Int32.to_int _i.it)
                in
                let typ_ = gettype modul_ (Int32.to_int typ_idx.it) in
                let _ti, _to =
                  (*list * list*)
                  match typ_ with FuncType (_ti, _to) -> (_ti, _to)
                in
                let _vals, ms' =
                  ( MS.peek_n_operand (List.length _ti) ms,
                    MS.pop_n_operand (List.length _ti) ms )
                in
                let ms'' = Cflow.prep_call ms' _vals modul_ locs typ_idx.it in
                let ms''', c', g =
                  fixpoint modul_ ((ms'', funbody), true) sk cache p_ans step
                in
                let _f_res =
                  MS.func_res (func_ans ms''') ms (List.length _to)
                in
                (Cflow.call_answer p_ans _f_res, c', g)
            | CallIndirect _ ->
                failwith
                  "callindirect, concretize ToS, filter by type, rewrite as \
                   Call"
            | Compare _r ->
                (cmd_result (Ops.eval_relop _r ms) p_ans, cache, SCG.empty)
            | Test t -> (cmd_result (Ops.eval_testop t ms) p_ans, cache, SCG.empty)
            | _ -> failwith "other commands"
          in
          let res2, cache'', scg_t =
            Cflow.monad_step res1 cache' (fun x ->
                fixpoint modul_
                  ((x.nat, c2), false)
                  sk cache' (pans_of_answer x) step)
          in
          (seq_result res1 res2, cache'', SCG.union scg_h scg_t))
