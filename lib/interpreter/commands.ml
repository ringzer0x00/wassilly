module MS = Memories.Frame

type module_ = Wasm.Ast.module_ (*or ' (?)*)
type p = Wasm.Ast.instr list

open Fixpoint
module Cache = Cache.Cache
module Stack = Stack.Stack
module SCG = Scg.SCC
module CallSet = Callset.CallSet
(*fp has wrong typing and parametrization, lacks continuation*)

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

let eval _module call _cstack _sk cache =
  let (ms : MS.t), (p : p) = call in
  match p with
  | [] -> failwith "" (*do labek stack stuff*)
  | h :: t ->
      let _nat_c = t in
      let ((_ms' : MS.t), _newsk), cache', scg =
        (*as opposed to ms this should return a vector of values which is then appended to the ms's operand stack*)
        match h.it with
        | Const num -> (Alu.const num ms, cache, SCG.empty)
        | Binary bop -> (Binops.eval_binop bop ms, cache, SCG.empty)
        | Unary uop -> (Unops.eval_unop uop ms, cache, SCG.empty)
        | Drop -> ((MS.pop_operand ms, []), cache, SCG.empty)
        | Nop -> ((ms, []), cache, SCG.empty)
        | Call _i ->
            failwith "call to fixpoint"
            (*before evaluating call push present natcont and other info to callstack*)
        | _ -> failwith "other commands"
      in
      let ms'' = MS.push _newsk _ms' in
      (ms'', cache', scg)
