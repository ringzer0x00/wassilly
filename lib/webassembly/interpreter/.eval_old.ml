open Datastructures.Monad.DefBot
module MS = Memories.Memorystate
module LM = Fixpoint.Labelmap.LabelMap
module MA = Fixpoint.Answer

type ans = MA.res Datastructures.Monad.DefBot.t
type module_ = Wasm.Ast.module_ (*or ' (?)*)
type p = Language.Command.Command.t

open Fixpoint
open Fixpoint.Answer
module Cache = Cache.Cache
module Stack = Stack.Stack
module SCG = Scg.SCC
module CallSet = Callgraph.CallGraph

let cg = ref CallSet.phi
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

let fixpoint _module (call, ifb) stack cache fin ft pres stepf =
  let _ms, _p = call in
  match ifb with
  | false -> stepf _module call stack cache fin ft pres
  | true -> (
      match Cache.call_in_cache call cache with
      | Some cached -> (
          let stable, resCached = cached in
          match stable with
          | Cache.Stable -> (resCached, cache, SCG.empty)
          | Cache.Unstable -> (resCached, cache, SCG.singleton call))
      | None -> (
          match Stack.call_in_stack call stack with
          | true -> (Bot, cache, SCG.singleton call)
          | false -> Iterate.iterate _module call stack cache fin ft pres stepf)
      )

(*eval should not be called recursively*)
let rec step modul_ call sk cache (fin : Int32.t) ft p_ans :
    ans * Cache.t * SCG.t =
  let (ms : MS.t), (p : p) = call in
  match ms with
  | Bot ->
      ( return { nat = Bot; return = p_ans.p_return; br = p_ans.p_br },
        cache,
        SCG.empty )
  | Def _ -> (
      match p with
      | [] ->
          if MS.is_lsk_empty ms then (
            Printf.printf "End of Func";
            (end_of_func ms p_ans, cache, SCG.empty))
          else
            let eob = Instructions.end_of_block ms modul_ in
            Printf.printf "Not end of Func";
            (cmd_result eob p_ans, cache, SCG.empty)
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
                let _ref = Memories.Operand.ref_of_binding _b Loc in
                (cmd_result (Instructions.read ms _ref) p_ans, cache, SCG.empty)
            | GlobalGet _var ->
                (*rewrite monadic*)
                let _b = MS.get_var_binding ms Glob _var.it in
                let _ref = Memories.Operand.ref_of_binding _b Glob in
                (cmd_result (Instructions.read ms _ref) p_ans, cache, SCG.empty)
            | Const num ->
                Printf.printf "Const\n\n";
                ( cmd_result (Instructions.const_val num ms) p_ans,
                  cache,
                  SCG.empty )
            | Binary bop ->
                (cmd_result (Ops.eval_binop bop ms) p_ans, cache, SCG.empty)
            | Unary uop ->
                (cmd_result (Ops.eval_unop uop ms) p_ans, cache, SCG.empty)
            | Drop -> (cmd_result (MS.pop_operand ms) p_ans, cache, SCG.empty)
            | Nop -> (cmd_result ms p_ans, cache, SCG.empty)
            | Br i ->
                let depth = Int32.to_int i.it in
                let _ff l ms =
                  (fun (x : Memories.Label.labelcontent) ms ->
                    fixpoint modul_
                      ((ms, x.brcont), true)
                      sk cache fin ft p_ans step)
                    l ms
                in
                Cflow.br depth ms p_ans cache modul_ ft _ff
            | Block (_bt, bbody) ->
                (*manca la parametrizzazione in input!!!!!*)
                let l =
                  Memories.Operand.Label
                    (Memories.Label.BlockLabel
                       { natcont = c2; brcont = c2; typ = _bt; cmd = [ c1 ] })
                in
                let ms' = Cflow.enter_label l ms modul_ in
                let a, c, g =
                  fixpoint modul_
                    ((ms', bbody), false)
                    sk cache fin ft p_ans step
                in
                (Cflow.block_result a [ c1 ], c, g)
            | Loop (_bt, lbody) ->
                (*manca la parametrizzazione in input!!!!!*)
                let _lab =
                  Memories.Operand.Label
                    (Memories.Label.LoopLabel
                       {
                         natcont = c2;
                         brcont = c1 :: c2;
                         typ = _bt;
                         cmd = [ c1 ];
                       })
                in
                let ms' = Cflow.enter_label _lab ms modul_ in
                let a, c, g =
                  fixpoint modul_
                    ((ms', lbody), true)
                    sk cache fin ft p_ans step
                in
                (Cflow.block_result a [ c1 ], c, g)
            | If (_blocktype, _then, _else) ->
                (*manca la parametrizzazione in input!!!!!*)
                let l =
                  Memories.Operand.Label
                    (Memories.Label.BlockLabel
                       {
                         natcont = c2;
                         brcont = c2;
                         typ = _blocktype;
                         cmd = [ c1 ];
                       })
                in
                let ms_t, ms_f = Cflow.ite_condition ms in
                let ms_t, ms_f =
                  ( Cflow.enter_label l ms_t modul_,
                    Cflow.enter_label l ms_f modul_ )
                in
                let print_dom_ms (ms : MS.t) s =
                  match ms with
                  | Def _d ->
                      Apron.Abstract1.print Format.std_formatter _d.var.ad
                  | Bot -> Printf.printf "Bot @ If (ms_dom) %s\n" s
                in
                let print_dom_ans (a : Answer.res t) s =
                  match a with
                  | Bot -> Printf.printf "Bot @ If (ans_dom) %s\n" s
                  | Def d ->
                      Printf.printf "Def @ if: \n";
                      print_dom_ms d.nat s
                in
                Printf.printf "Doms for MS_t, MS_f";
                print_dom_ms ms_t "true";
                print_dom_ms ms_f "false";
                let a_true, c', _scgt =
                  fixpoint modul_
                    ((ms_t, _then), false)
                    sk cache fin ft p_ans step
                in
                let a_true = Cflow.block_result a_true [ c1 ] in
                print_dom_ans a_true "\ntrue~~~~~";
                let a_false, c'', _scgf =
                  fixpoint modul_ ((ms_f, _else), false) sk c' fin ft p_ans step
                in
                let a_false = Cflow.block_result a_false [ c1 ] in
                print_dom_ans a_false "false\n\n";
                let a, scg = (MA.lub a_true a_false, SCG.union _scgt _scgf) in
                let a = Cflow.test_lub_pans a p_ans in
                (a, c'', scg)
            | BrIf _i ->
                let ms_t, ms_f = Cflow.ite_condition ms in
                let depth = Int32.to_int _i.it in
                let fixf l ms =
                  (fun (x : Memories.Label.labelcontent) ms ->
                    fixpoint modul_
                      ((ms, x.brcont), true)
                      sk cache fin ft p_ans step)
                    l ms
                in
                let _a_t, c', scg =
                  Cflow.br depth ms_t p_ans cache modul_ ft fixf
                in
                let ans =
                  match _a_t with
                  | Def d ->
                      return
                        {
                          nat = ms_f;
                          return = MS.join p_ans.p_return d.return;
                          br = LM.lub p_ans.p_br d.br;
                        }
                  | Bot ->
                      return
                        { nat = ms_f; return = p_ans.p_return; br = p_ans.p_br }
                in
                (ans, c', scg)
            | Return ->
                let _, _t = ft in
                let _retvals = MS.peek_n_operand (List.length _t) ms in
                let ms' = MS.update_operandstack _retvals ms in
                ( return
                    {
                      nat = Bot;
                      br = LM.empty;
                      return = MS.join p_ans.p_return ms';
                    },
                  cache,
                  SCG.empty )
            | Call _i ->
                Printf.printf "CALL %i\n\n" (Int32.to_int _i.it);
                cg := CallSet.union (CallSet.singleton (fin, _i.it)) !cg;
                let fin' = _i.it in
                let funbody, locs, typ_idx =
                  getfbody modul_ (Int32.to_int _i.it)
                in
                let _flab =
                  Memories.Label.BlockLabel
                    {
                      typ = Wasm.Ast.VarBlockType _i;
                      cmd = funbody;
                      natcont = [];
                      brcont = [];
                    }
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
                let ms'' =
                  Cflow.prep_call ms' _vals modul_ locs typ_idx.it
                    typ_idx (*flab*)
                in
                let ms''', c', g =
                  fixpoint modul_
                    ((ms'', funbody), true)
                    sk cache fin' (_ti, _to) p_ans step
                in
                let _f_res =
                  MS.func_res (func_ans ms''') ms' (List.length _to)
                in
                (Cflow.call_answer p_ans _f_res, c', g)
            | CallIndirect (_fsign, _table_idx) ->
                let _ti, _to =
                  match gettype modul_ (Int32.to_int _fsign.it) with
                  | FuncType (_ti, _to) -> (_ti, _to)
                in
                let expr_idx, ms' =
                  (MS.peek_n_operand 1 ms |> List.hd, MS.pop_operand ms)
                in
                let _interval_idx = MS.operand_as_interval expr_idx ms in
                let _refs =
                  MS.table_getrefs _interval_idx (Some _fsign.it) ms'
                in
                let _targets =
                  List.map
                    (fun x -> fst (snd x))
                    (Memories.Table.T.bindings _refs)
                  |> List.filter_map (fun x -> x)
                in
                List.iter
                  (fun x ->
                    cg := CallSet.union (CallSet.singleton (fin, x)) !cg)
                  _targets;
                let typ_ = gettype modul_ (Int32.to_int _fsign.it) in
                let _ti, _to =
                  (*list * list*)
                  match typ_ with FuncType (_ti, _to) -> (_ti, _to)
                in
                let _vals, _ms'' =
                  ( MS.peek_n_operand (List.length _ti) ms',
                    MS.pop_n_operand (List.length _ti) ms' )
                in
                let funcs =
                  List.map
                    (fun x -> (getfbody modul_ (Int32.to_int x), x))
                    _targets
                in
                let _mses_prepped =
                  List.map
                    (fun ((_f, _locs, (typ_idx : Wasm.Ast.var)), _) ->
                      Cflow.prep_call _ms'' _vals modul_ _locs typ_idx.it
                        typ_idx)
                    funcs
                in
                let computed, cache', scg =
                  List.fold_left2
                    (fun (a, c, g) m ((f, _, _), fin') ->
                      let a', c', g' =
                        fixpoint modul_
                          ((m, f), true)
                          sk c fin' (_ti, _to) p_ans step
                      in
                      (Answer.j a a', c', SCG.union g g'))
                    (Bot, cache, SCG.empty) _mses_prepped funcs
                in
                let _f_res =
                  MS.func_res (func_ans computed) ms' (List.length _to)
                in
                (Cflow.call_answer p_ans _f_res, cache', scg)
            | Compare _r ->
                (cmd_result (Ops.eval_relop _r ms) p_ans, cache, SCG.empty)
            | Test t ->
                (cmd_result (Ops.eval_testop t ms) p_ans, cache, SCG.empty)
            | RefFunc v ->
                let intval = v.it in
                let _, _, ftype = getfbody modul_ (Int32.to_int intval) in
                let resex =
                  Memories.Operand.FuncRef
                    (Wasm.Types.FuncRefType, Some intval, Some ftype.it)
                in
                (cmd_result (Instructions.read ms resex) p_ans, cache, SCG.empty)
            | RefNull t ->
                let resex = Memories.Operand.FuncRef (t, None, None) in
                (cmd_result (Instructions.read ms resex) p_ans, cache, SCG.empty)
            | RefIsNull -> failwith ""
            | Convert c ->
                (cmd_result (Ops.eval_cvtop c ms) p_ans, cache, SCG.empty)
            | Load l ->
                (cmd_result (Ops.eval_loadop l ms) p_ans, cache, SCG.empty)
            | Store s ->
                (cmd_result (Ops.eval_storeop s ms) p_ans, cache, SCG.empty)
            | _ ->
                Wasm.Print.instr Stdlib.stdout 100 c1;
                failwith "other commands"
          in
          let res2, cache'', scg_t =
            Cflow.monad_step res1 cache' (fun x ->
                fixpoint modul_
                  ((x.nat, c2), false)
                  sk cache' fin ft (pans_of_answer x) step)
          in
          (seq_result res1 res2, cache'', SCG.union scg_h scg_t))