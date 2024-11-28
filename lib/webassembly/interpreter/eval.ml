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
              | Cache.Stable ->
                  printer Format.print_string "STABLE\n";
                  (resCached, cache, SCG.empty)
              | Cache.Unstable ->
                  printer Format.print_string "UNSTABLE\n";
                  (resCached, cache, SCG.singleton call))
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
  (*match ms with
    | Bot ->
        ( return { nat = Bot; return = p_ans.p_return; br = p_ans.p_br },
          cache,
          SCG.empty )
    | Def _ -> ( *)
  match p with
  | [] ->
      if MS.is_lsk_empty ms then (end_of_func ms p_ans, cache, SCG.empty)
      else
        let eob = Instructions.end_of_block ms modi in
        (cmd_result eob p_ans, cache, SCG.empty)
  | c1 :: c2 ->
      let msg = Printf.sprintf "in %i, eval:" (Int32.to_int fin) in
      printer Format.print_string msg;
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
            let to_interval = Memories.Memorystate.operand_as_interval ref ms in
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
            let to_interval = Memories.Memorystate.operand_as_interval ref ms in
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
            (cmd_result (Instructions.const_val num ms) p_ans, cache, SCG.empty)
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
                fixpoint modi ((ms, x.brcont), true) sk cache fin ft p_ans step)
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
                   { natcont = c2; brcont = c1 :: c2; typ = _bt; cmd = [ c1 ] })
            in
            let ms' = Cflow.enter_label _lab ms modi in
            let a, c, g =
              fixpoint modi ((ms', lbody), false) sk cache fin ft p_ans step
            in
            (Cflow.block_result a [ c1 ], c, g)
        | If (_blocktype, _then, _else) ->
            let l =
              Memories.Operand.Label
                (Memories.Label.BlockLabel
                   { natcont = c2; brcont = c2; typ = _blocktype; cmd = [ c1 ] })
            in
            let ms_t, ms_f = Cflow.ite_condition ms in
            let ms_t, ms_f =
              (Cflow.enter_label l ms_t modi, Cflow.enter_label l ms_f modi)
            in
            let a_true, c', _scgt =
              fixpoint modi ((ms_t, _then), false) sk cache fin ft p_ans step
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
            let fixf l mem =
              (fun (x : Memories.Label.labelcontent) m ->
                fixpoint modi ((m, x.cmd), true) sk cache fin ft p_ans step)
                l mem
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
            cg := CallGraph.add_edge !cg fin _i.it;
            let fin' = _i.it in
            let f = getfbody_wrapped modi (Int32.to_int _i.it) in
            let fres, cache', g =
              match f with
              | Memories.Instance.ImportedFunc term ->
                  let _n, _fs, _impl = Importspec.Helpers.getfuncspec term in
                  (*call spec_eval.eval*)
                  let _res, _cs = Spec_eval.eval term ms modi in
                  let called_idxex =
                    List.map (fun (Importspec.Term.Calls x) -> (_i.it, x)) _cs
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
                    Cflow.prep_call ms' _vals modi locs typ_idx.it
                    (*flab*)
                  in
                  let ms''', c', g =
                    fixpoint modi
                      ((ms'', funbody), true)
                      sk cache fin' (_ti, _to) p_ans step
                  in
                  (MS.func_res (func_ans ms''') ms' (List.length _to), c', g)
            in
            (Cflow.call_answer p_ans fres, cache', g)
        | CallIndirect (_fsign, _table_idx) ->
            let _ti, _to =
              match gettype modi (Int32.to_int _fsign.it) with
              | FuncType (_ti, _to) -> (_ti, _to)
            in
            let expr_idx, ms' =
              (MS.peek_n_operand 1 ms |> List.hd, MS.pop_operand ms)
            in
            let _interval_idx = MS.operand_as_interval expr_idx ms in
            let _refs = MS.table_getrefs _interval_idx (Some _fsign.it) ms' in
            let _targets =
              List.map (fun x -> fst (snd x)) (Memories.Table.T.bindings _refs)
              |> List.filter_map (fun x -> x)
            in
            List.iter (fun x -> cg := CallGraph.add_edge !cg fin x) _targets;
            let typ_ = gettype modi (Int32.to_int _fsign.it) in
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
                (fun x -> (getfbody_wrapped modi (Int32.to_int x), x))
                _targets
            in
            let mses_called =
              List.map
                (fun (f, fidx) ->
                  match f with
                  | Memories.Instance.ImportedFunc term ->
                      let _n, _fs, _impl =
                        Importspec.Helpers.getfuncspec term
                      in
                      (*call spec_eval.eval*)
                      let _res, _cs = Spec_eval.eval term _ms'' modi in
                      let called_idxex =
                        List.map
                          (fun (Importspec.Term.Calls x) -> (fidx, x))
                          _cs
                      in
                      List.iter
                        (fun (s, d) -> cg := CallGraph.add_edge !cg s d)
                        called_idxex;
                      (_res, cache, SCG.empty)
                  | Memories.Instance.Func f ->
                      let fbody, _locs, (typ_idx : Wasm.Ast.var) =
                        (f.it.body, f.it.locals, f.it.ftype)
                      in
                      let ms_prepped =
                        Cflow.prep_call _ms'' _vals modi _locs typ_idx.it
                      in
                      let ms''', c', g =
                        fixpoint modi
                          ((ms_prepped, fbody), true)
                          sk cache fin (_ti, _to) p_ans step
                      in
                      (ms''', c', g))
                funcs
            in
            let computed, cache', scg =
              List.fold_left
                (fun (a, c, g) (a', c', g') ->
                  (Answer.j a a', Cache.lub c c', SCG.union g g'))
                (Bot, cache, SCG.empty) mses_called
            in
            let _f_res =
              MS.func_res (func_ans computed) ms' (List.length _to)
            in
            (Cflow.call_answer p_ans _f_res, cache', scg)
        | Compare _r ->
            (cmd_result (Ops.eval_relop _r ms) p_ans, cache, SCG.empty)
        | Test t -> (cmd_result (Ops.eval_testop t ms) p_ans, cache, SCG.empty)
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
        | Convert c -> (cmd_result (Ops.eval_cvtop c ms) p_ans, cache, SCG.empty)
        | Load l -> (cmd_result (Ops.eval_loadop l ms) p_ans, cache, SCG.empty)
        | Store s -> (cmd_result (Ops.eval_storeop s ms) p_ans, cache, SCG.empty)
        | Unreachable -> (cmd_result Bot p_ans, cache, SCG.empty)
        | Select _rt ->
            (cmd_result (Instructions.select ms _rt) p_ans, cache, SCG.empty)
        | _ ->
            Wasm.Print.instr Stdlib.stdout 100 c1;
            failwith "other commands"
      in
      (*let res2, cache'', scg_t =*)
      Cflow.monad_step res1 cache' (fun x ->
          fixpoint modi
            ((x.nat, c2), false)
            sk cache' fin ft (pans_of_answer x) step)
(*in
  (seq_result res1 res2, cache'', SCG.union scg_h scg_t)*)
(* ) *)
