open Command.Language
open Command
open Stronglyconnected

let mgr = Aprond.new_mgr "polystrict"
let cst_to_val i = Apron.Interval.of_int i i

let wStack stack ((env1, expr) as call : Call.t) =
  match Stack.Stack.expr_in_stack expr stack with
  | false ->
      Format.print_string "expression not in stack\n";
      Format.print_flush ();
      (Stack.Stack.add expr env1 stack, call)
  | true ->
      let env2 = Stack.Stack.find expr stack in
      if Memory.Memory.included mgr env1 env2 then (
        Format.print_string "env in stack is bigger\n";
        Format.print_flush ();
        (stack, (env2, expr)))
      else (
        Format.print_string "env in stack is smaller, widening\n";
        Format.print_flush ();
        let envWidened = Memory.Memory.widen mgr env2 env1 in
        (Stack.Stack.add expr envWidened stack, (envWidened, expr)))

let wVal = Value.valueWidening
let call_in_cache call cache = Cache.Cache.find_opt call cache

let call_in_stack (env, expr) stack =
  match Stack.Stack.find_opt expr stack with
  | Some envStack -> env = envStack
  | None -> false

let rec eval funcs call stack cache =
  let env, expr = call in
  match expr with
  | Var v -> (Memory.Memory.find mgr v env, cache, SCC.empty)
  | Num i -> (cst_to_val i, cache, SCC.empty)
  | Add (l, r) ->
      let l_val, cache', _l_scg' =
        fixpoint funcs ((env, l), false) stack cache
      in
      let r_val, cache'', _r_scg' =
        fixpoint funcs ((env, r), false) stack cache'
      in
      let r = Math.sum mgr l_val r_val env in
      (r, cache'', SCC.union _l_scg' _r_scg')
  | Mul (l, r) ->
      let l_val, cache', _l_scg' =
        fixpoint funcs ((env, l), false) stack cache
      in
      let r_val, cache'', _r_scg' =
        fixpoint funcs ((env, r), false) stack cache'
      in
      let r = Math.mul mgr l_val r_val env in
      (r, cache'', SCC.union _l_scg' _r_scg')
  | Sub (l, r) ->
      let l_val, cache', _l_scg' =
        fixpoint funcs ((env, l), false) stack cache
      in
      let r_val, cache'', _r_scg' =
        fixpoint funcs ((env, r), false) stack cache'
      in
      (Math.sub mgr l_val r_val env, cache'', SCC.union _l_scg' _r_scg')
  (*| If (_c, _t, _e) ->
      let t_val, _cache', _scgt =
        fixpoint funcs ((env, _t), false) stack cache
      in
      let f_val, _cache'', _scgh =
        fixpoint funcs ((env, _e), false) stack _cache'
      in

      (Value.lub t_val f_val, _cache'', SCC.union _scgh _scgt)*)
  | If (_c, _t, _e) ->
      (*if-filtered*)
      let cons_true, cons_false = Constraint.bexpr_as_tcons env _c in
      let envtrue, envfalse =
        ( Constraint.filter mgr env cons_true,
          Constraint.filter mgr env cons_false )
      in
      let t_val, _cache', _scgt =
        if Apron.Abstract1.is_bottom mgr envtrue then
          (Value.bot, cache, SCC.empty)
        else fixpoint funcs ((envtrue, _t), false) stack cache
      in
      let f_val, _cache'', _scgh =
        if Apron.Abstract1.is_bottom mgr envfalse then
          (Value.bot, cache, SCC.empty)
        else fixpoint funcs ((envfalse, _e), false) stack _cache'
      in

      (Value.lub t_val f_val, _cache'', SCC.union _scgh _scgt)
  | Call (fname, args) ->
      let pars, body = Funcs.find fname funcs in

      (*let val_, cache', _scg =
          fixpoint funcs ((env, List.nth args 0), false) stack cache
        in*)
      let vallist, cache', _scg' =
        List.fold_left
          (fun (v, c, g) arg ->
            let v', c', g' = fixpoint funcs ((env, arg), false) stack c in
            (v' :: v, c', SCC.union g' g))
          ([], cache, SCC.empty) (List.rev args)
      in

      (*arg is expression, a value is needed*)
      let env' =
        List.fold_left2
          (fun m x y -> Memory.Memory.add mgr x y m)
          (Memory.Memory.make_empty mgr)
          pars vallist (*[ val_ ]*)
      in
      let env' = if Memory.Memory.included mgr env' env then env else env' in
      (*match Cache.Cache.find_opt (env', body) cache' with
        | Some _ -> failwith "cached?"
        | None ->*)
      fixpoint funcs ((env', body), true) stack cache'

and iterate funcs call stack cache1 =
  let stackWidened, callWidened = wStack stack call in
  Format.print_string "Stack:";
  Stack.Stack.print stackWidened;
  let valNew, cache2, scg = eval funcs callWidened stackWidened cache1 in
  Format.print_string "\n Iterate: ~New:";
  Apron.Interval.print Format.std_formatter valNew;
  if SCC.mem callWidened scg then (
    Format.print_string "SCG";
    let valOld =
      if Cache.Cache.mem callWidened cache2 then
        snd (Cache.Cache.find callWidened cache2)
      else Value.bot
    in
    Format.print_string "\n ~Old";
    Apron.Interval.print Format.std_formatter valOld;

    let valWidened = wVal valOld valNew in
    Format.print_string "\n Result: ";
    Apron.Interval.print Format.std_formatter valWidened;

    let stable =
      if Value.included valWidened valOld && SCC.cardinal scg = 1 then
        Cache.Stable
      else Cache.Unstable
    in
    let cache3 = Cache.Cache.add callWidened (stable, valWidened) cache2 in
    if Value.smaller valOld valWidened then iterate funcs call stack cache3
    else (valWidened, cache3, SCC.diff scg (SCC.singleton callWidened)))
  else (valNew, cache2, scg)

and fixpoint funcs (((_env, _expr) as call), ifb) stack cache =
  let v, c, scg =
    match ifb with
    | false -> eval funcs call stack cache (*c1*)
    | true -> (
        match call_in_cache call cache with
        | Some cached -> (
            let stable, valCached = cached in
            match stable with
            | Cache.Stable -> (valCached, cache, SCC.empty)
            | Cache.Unstable -> (valCached, cache, SCC.singleton call))
        | None -> (
            match call_in_stack call stack with
            | true -> (Value.bot, cache, SCC.singleton call)
            | false -> iterate funcs call stack cache))
  in
  (v, c, scg)
