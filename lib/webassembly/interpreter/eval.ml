open Datastructures.Monad.DefBot
module MS = Memories.Memorystate
module LM = Fixpoint.Labelmap.LabelMap
module MA = Fixpoint.Answer

type ans = MA.res Datastructures.Monad.DefBot.t
type module_ = Memories.Instance.instance (*or ' (?)*)
type p = Language.Command.Command.t

open Fixpoint
open Fixpoint.Answer
module Cache = Cache.Cache
module Stack = Stack.Stack
module SCG = Scg.SCC
module CallGraph = Datastructures.Callgraph.Ga

let printer = Utilities.Printer.print
let cg = ref CallGraph.phi
let cmd_result = Cflow.simplecmd_answer
let seq_result = Cflow.seq_answer
let func_ans = Cflow.func_answer
let pans_of_answer = MA.pans_of_answer
let end_of_func = Cflow.end_of_func
let getfbody_wrapped (mod_ : module_) idx = List.nth mod_.funcs idx

let getfbody (mod_ : module_) idx =
  let funx = List.nth mod_.funcs idx in
  match funx with
  | Func f -> (f.it.body, f.it.locals, f.it.ftype)
  | ImportedFunc (Importspec.Term.Func (_, _, _)) ->
      failwith "imported functtion @ eval.ml"
  | _ -> failwith "outside patternmatching @ getfbody"

let gettype (mod_ : module_) idx =
  let t = List.nth mod_.types idx in
  t.it

let fixpoint _module (call, ifb) stack cache fin ft pres stepf =
  let _ms, _p = call in
  match _ms with
  | Bot -> (Bot, cache, SCG.empty)
  | _ -> (
      match ifb with
      | false -> stepf _module call stack cache fin ft pres
      | true -> (
          printer Format.print_string "{Fixpoint computation}: ";
          match Cache.call_in_cache call cache with
          | Some cached -> (
              printer Format.print_string "Cached: ";
              let stable, resCached = cached in
              match stable with
              | Cache.Stable -> (resCached, cache, SCG.empty)
              | Cache.Unstable -> (resCached, cache, SCG.singleton call))
          | None -> (
              printer Format.print_string "NOT Cached: ";
              match Stack.call_in_stack call stack with
              | true ->
                  printer Format.print_string "return BOT\n";
                  (Bot, cache, SCG.singleton call)
              | false ->
                  Iterate.iterate _module call stack cache fin ft pres stepf)))

(*eval should not be called recursively*)
let rec step (modi : module_) call sk cache (fin : Int32.t) ft p_ans :
    ans * Cache.t * SCG.t =
  let (ms : MS.t), (p : p) = call in
  match ms with
  | Bot ->
      ( return { nat = Bot; return = p_ans.p_return; br = p_ans.p_br },
        cache,
        SCG.empty )
  | Def d -> (
      match p with
      | [] ->
          if MS.is_lsk_empty ms then (
            printer Format.print_string
              (Printf.sprintf "EOF %s" (Int32.to_string fin));
            (end_of_func ms p_ans, cache, SCG.empty))
          else
            let eob = Instructions.end_of_block ms p_ans modi in
            (cmd_result eob p_ans, cache, SCG.empty)
      | c1 :: c2 ->
          let msg = Printf.sprintf "\nin %i, eval:" (Int32.to_int fin) in
          let msg_sklen =
            Printf.sprintf "Stack length: %i\n" (List.length d.ops)
          in
          printer Format.print_string msg;
          printer Format.print_string msg_sklen;
          printer (Wasm.Print.instr Stdlib.stdout 100) c1;
          let (res1 : ans), cache', _scg_h =
            (*as opposed to ms this should return a vector of values which is then appended to the ms's operand stack*)
            match c1.it with
            | LocalSet var ->
                let val_, ms' =
                  (MS.peek_operand ms |> List.hd, MS.pop_operand ms)
                in
                printer Format.print_string "\t~ Assigning:";
                printer Memories.Operand.print_operand val_;
                let to_interval =
                  Memories.Memorystate.operand_as_interval val_ ms'
                in
                printer
                  (Apronext.Intervalext.print Format.std_formatter)
                  to_interval;
                let b = MS.get_var_binding ms' Loc var.it in
                let ms' = MS.assign_var ms' Loc b val_ in
                (cmd_result ms' p_ans, cache, SCG.empty)
            | GlobalSet var ->
                let val_, ms' =
                  (MS.peek_operand ms |> List.hd, MS.pop_operand ms)
                in
                printer Format.print_string "\t~ Assigning:";
                printer Memories.Operand.print_operand val_;
                printer Format.print_string "\n\t# (when concretized:";
                let to_interval =
                  Memories.Memorystate.operand_as_interval val_ ms'
                in
                printer
                  (Apronext.Intervalext.print Format.std_formatter)
                  to_interval;
                printer Format.print_string ")";
                printer Format.print_newline ();
                let b = MS.get_var_binding ms' Glob var.it in
                let ms' = MS.assign_var ms' Glob b val_ in
                (cmd_result ms' p_ans, cache, SCG.empty)
            | LocalGet var ->
                let b = MS.get_var_binding ms Loc var.it in
                let ref = Memories.Operand.ref_of_binding b Loc in
                printer Format.print_string "\t~ Getting:";
                printer Memories.Operand.print_operand ref;
                printer Format.print_string "\n\t# (when concretized:";
                let to_interval =
                  Memories.Memorystate.operand_as_interval ref ms
                in
                printer
                  (Apronext.Intervalext.print Format.std_formatter)
                  to_interval;
                printer Format.print_string ")";
                printer Format.print_newline ();
                (cmd_result (Instructions.read ms ref) p_ans, cache, SCG.empty)
            | GlobalGet var ->
                let b = MS.get_var_binding ms Glob var.it in
                let ref = Memories.Operand.ref_of_binding b Glob in
                printer Format.print_string "\t~ Getting:";
                printer Memories.Operand.print_operand ref;
                printer Format.print_string "\n\t# (when concretized:";
                let to_interval =
                  Memories.Memorystate.operand_as_interval ref ms
                in
                printer
                  (Apronext.Intervalext.print Format.std_formatter)
                  to_interval;
                printer Format.print_string ")";
                printer Format.print_newline ();
                (cmd_result (Instructions.read ms ref) p_ans, cache, SCG.empty)
            | LocalTee var ->
                let val_, ms' =
                  (MS.peek_operand ms |> List.hd, MS.pop_operand ms)
                in
                let b = MS.get_var_binding ms' Loc var.it in
                let ms' = MS.assign_var ms' Loc b val_ in
                let ref = Memories.Operand.ref_of_binding b Loc in
                (cmd_result (Instructions.read ms' ref) p_ans, cache, SCG.empty)
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
            | Br i ->
                let depth = Int32.to_int i.it in
                let _ff l ms =
                  (fun body ms ->
                    fixpoint modi ((ms, body), true) sk cache fin ft p_ans step)
                    l ms
                in
                Cflow.br depth ms p_ans cache modi ft _ff
            | Block (_bt, bbody) ->
                let l =
                  Memories.Operand.Label
                    (Memories.Label.BlockLabel
                       { natcont = c2; brcont = c2; typ = _bt; cmd = [ c1 ] })
                in
                let ms' = Cflow.enter_label l ms modi in
                let a, c, g =
                  fixpoint modi ((ms', bbody), false) sk cache fin ft p_ans step
                in
                (Cflow.block_result a [ c1 ], c, g)
            | Loop (_bt, lbody) ->
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
                let ms' = Cflow.enter_label _lab ms modi in
                let a, c, g =
                  fixpoint modi ((ms', lbody), true) sk cache fin ft p_ans step
                in
                (Cflow.loop_result a [ c1 ], c, g)
            | If (_blocktype, _then, _else) ->
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
                  (Cflow.enter_label l ms_t modi, Cflow.enter_label l ms_f modi)
                in
                let a_true, c', _scgt =
                  fixpoint modi
                    ((ms_t, _then), false)
                    sk cache fin ft p_ans step
                in
                let a_true = Cflow.block_result a_true [ c1 ] in
                let a_false, c'', _scgf =
                  fixpoint modi ((ms_f, _else), false) sk c' fin ft p_ans step
                in
                let a_false = Cflow.block_result a_false [ c1 ] in
                let a, scg = (MA.lub a_true a_false, SCG.union _scgt _scgf) in
                let a = Cflow.test_lub_pans a p_ans in
                (a, c'', scg)
            | BrIf _i ->
                let ms_t, ms_f = Cflow.ite_condition ms in
                let depth = Int32.to_int _i.it in
                printer Format.print_string "~~~~~~ briffing \n";
                let fixf body mem =
                  (fun body m ->
                    fixpoint modi ((m, body), true) sk cache fin ft p_ans step)
                    body mem
                in
                let _a_t, c', scg =
                  match ms_t with
                  | Bot ->
                      printer Format.print_string "~~~~~~ briffing -> BOT \n";
                      (Bot, cache, SCG.empty)
                  | _ ->
                      printer Format.print_string "~~~~~~ briffing -> BR \n";
                      Cflow.br depth ms_t p_ans cache modi ft fixf
                in
                printer Format.print_string
                  "~~~~~~ briffing -> i have an answer!!! \n";
                let ans =
                  match _a_t with
                  | Def d ->
                      let br' = LM.lub p_ans.p_br d.br in
                      let br' =
                        match MS.peek_nth_label ms depth with
                        | None -> br'
                        | Some c -> (
                            match c with
                            | Label (LoopLabel c) -> LM.add_lub c.cmd d.nat br'
                            | _ -> br')
                      in
                      return
                        {
                          nat = (*MS.join d.nat*) ms_f;
                          (*comment on 29 nov 2024, non credo ci vada il join in nat*)
                          return = MS.join p_ans.p_return d.return;
                          br = br';
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
                      br = p_ans.p_br;
                      return = MS.join p_ans.p_return ms';
                    },
                  cache,
                  SCG.empty )
            | Call _i ->
                cg := CallGraph.add_edge !cg fin _i.it;
                let fin' = _i.it in
                let f = getfbody_wrapped modi (Int32.to_int _i.it) in
                let fres, cache', g =
                  match f with
                  | Memories.Instance.ImportedFunc term ->
                      let _n, _fs, _impl =
                        Importspec.Helpers.getfuncspec term
                      in
                      (*call spec_eval.eval*)
                      let _res, _cs = Spec_eval.eval term ms modi in
                      let called_idxex =
                        List.map
                          (fun (Importspec.Term.Calls x) -> (_i.it, x))
                          _cs
                      in
                      List.iter
                        (fun (s, d) -> cg := CallGraph.add_edge !cg s d)
                        called_idxex;
                      (func_ans _res, cache, SCG.empty)
                  | Memories.Instance.Func f ->
                      let funbody, locs, typ_idx =
                        (f.it.body, f.it.locals, f.it.ftype)
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
                      let typ_ = gettype modi (Int32.to_int typ_idx.it) in
                      let _ti, _to =
                        (*list * list*)
                        match typ_ with FuncType (_ti, _to) -> (_ti, _to)
                      in
                      let _vals, ms' =
                        ( MS.peek_n_operand (List.length _ti) ms,
                          MS.pop_n_operand (List.length _ti) ms )
                      in
                      let ms'' =
                        try Cflow.prep_call ms' _vals modi locs typ_idx.it
                        with UndefinedDefBot -> Bot
                        (*flab*)
                      in
                      let ms''', c', g =
                        fixpoint modi
                          ((ms'', funbody), true)
                          sk cache fin' (_ti, _to) Fixpoint.Answer.bot_pa step
                      in
                      (MS.func_res (func_ans ms''') ms' (List.length _to), c', g)
                  (*error should be here in the change of ctx when calling*)
                in
                (Cflow.call_answer p_ans fres, cache', g)
            | CallIndirect (table_idx, fsign) ->
                let _ti, _to =
                  match gettype modi (Int32.to_int fsign.it) with
                  | FuncType (_ti, _to) -> (_ti, _to)
                in
                let expr_idx, ms' =
                  (MS.peek_n_operand 1 ms |> List.hd, MS.pop_operand ms)
                in
                let interval_idx = MS.operand_as_interval expr_idx ms in
                let refs_map =
                  MS.table_getrefs
                    (Int32.to_int table_idx.it)
                    interval_idx (Some fsign.it) ms'
                in
                let targets =
                  List.map
                    (fun x -> snd x |> fst)
                    (Memories.Table.T.bindings refs_map)
                in
                let targets =
                  List.filter_map (fun x -> x) targets
                  |> List.sort_uniq Int32.compare
                in
                Printf.printf "fun to call:\n";
                List.iter
                  (fun x -> Printf.printf "%i,\n" (Int32.to_int x))
                  targets;
                Printf.printf "==============================\n";
                Format.print_flush ();
                List.iter (fun x -> cg := CallGraph.add_edge !cg fin x) targets;
                let typ_ = gettype modi (Int32.to_int fsign.it) in
                let tin, tout =
                  (*list * list*)
                  match typ_ with FuncType (_ti, _to) -> (_ti, _to)
                in
                let args_val, ms'' =
                  ( MS.peek_n_operand (List.length tin) ms',
                    MS.pop_n_operand (List.length tin) ms' )
                in
                let funcs =
                  List.map
                    (fun x -> (getfbody_wrapped modi (Int32.to_int x), x))
                    targets
                in

                let feval ms (f, fin') cache =
                  match f with
                  | Memories.Instance.ImportedFunc term ->
                      let res, calls = Spec_eval.eval term ms modi in
                      let edges =
                        List.map
                          (fun (Importspec.Term.Calls x) -> (fin', x))
                          calls
                      in
                      List.iter
                        (fun (s, d) -> cg := CallGraph.add_edge !cg s d)
                        edges;
                      (res, cache, SCG.empty)
                  | Memories.Instance.Func f ->
                      let fbody, locs, (typ_idx : Wasm.Ast.var) =
                        (f.it.body, f.it.locals, f.it.ftype)
                      in
                      let ms_prepped =
                        try Cflow.prep_call ms args_val modi locs typ_idx.it
                        with UndefinedDefBot -> Bot
                      in
                      fixpoint modi
                        ((ms_prepped, fbody), true)
                        sk cache fin' (tin, tout) Fixpoint.Answer.bot_pa step
                in
                let computed, cache', scg =
                  List.fold_left
                    (fun (a, c, g) (f, fidx) ->
                      let a', c', g' = feval ms'' (f, fidx) c in
                      ( MS.join a
                          (MS.func_res (func_ans a') ms''
                             (*used to be ms'*) (List.length tout)),
                        c',
                        SCG.union g g' ))
                    (Bot, cache, SCG.empty) funcs
                in
                (Cflow.call_answer p_ans computed, cache', scg)
            | Compare _r ->
                (cmd_result (Ops.eval_relop _r ms) p_ans, cache, SCG.empty)
            | Test t ->
                (cmd_result (Ops.eval_testop t ms) p_ans, cache, SCG.empty)
            | RefFunc v ->
                let intval = v.it in
                let _, _, ftype = getfbody modi (Int32.to_int intval) in
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
            | Unreachable -> (cmd_result Bot p_ans, cache, SCG.empty)
            | Select _rt ->
                (cmd_result (Instructions.select ms _rt) p_ans, cache, SCG.empty)
            | MemorySize ->
                (cmd_result (Instructions.mem_size ms) p_ans, cache, SCG.empty)
            | MemoryGrow ->
                ( cmd_result
                    (*(Instructions.grow (*pops and returns new pagesize*)*) ms
                    p_ans,
                  cache,
                  SCG.empty )
            | BrTable (_branches, _default) ->
                let ms' = MS.pop_operand ms in
                let fixf body ms =
                  (fun body ms ->
                    fixpoint modi ((ms, body), true) sk cache fin ft p_ans step)
                    body ms
                in

                List.fold_left
                  (fun (ans, cache, scg) depth ->
                    let ans', cache', scg' =
                      Cflow.br depth ms' p_ans cache modi ft fixf
                    in
                    (Answer.j ans ans', cache', SCG.union scg scg'))
                  (cmd_result Bot p_ans, cache, SCG.empty)
                  (List.map
                     (fun (x : Wasm.Ast.var) -> Int32.to_int x.it)
                     (_branches @ [ _default ]))
            | _ ->
                Wasm.Print.instr Stdlib.stdout 100 c1;
                failwith "other commands"
          in
          (*
          let res2, cache'', scg_t =*)
          Cflow.monad_step res1 cache' (fun x ->
              fixpoint modi
                ((x.nat, c2), false)
                sk cache' fin ft (pans_of_answer x) step)
          (* in
             (seq_result res1 res2, cache'', SCG.union _scg_h scg_t)*))
