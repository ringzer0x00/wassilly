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

let (*rec*) fixpoint _module (call, ifb) _cstack _cont stack cache =
  let eval _module call _cstack _cont _sk _cache =
    let (ms : MS.t), (p : p) = call in
    match p with
    | [] -> failwith ""
    | h :: t ->
        let _nat_c = t in
        let (_ms' : MS.t), _cache, _scg, _called =
          match h.it with
          | Binary _bop ->
              (Binops.eval_binop _bop ms, cache, SCG.empty, CallSet.empty)
          | Unary _uop ->
              (Unops.eval_unop _uop ms, cache, SCG.empty, CallSet.empty)
          | Drop -> (MS.pop_operand ms, cache, SCG.empty, CallSet.empty)
          | Nop -> (ms, cache, SCG.empty, CallSet.empty)
          | Call _i ->
              failwith "call to fixpoint"
              (*before evaluating call push present natcont and other info to callstack*)
          | _ -> failwith ""
        in
        failwith ""
  in
  let _ms, _p = call in
  let _out =
    match ifb with
    | false -> eval _module call stack cache
    | true -> (
        match Cache.call_in_cache call cache with
        | Some cached -> (
            let stable, _valCached = cached in
            match stable with
            | Cache.Stable -> failwith ""
            | Cache.Unstable -> failwith "")
        | None -> (
            match Stack.call_in_stack call stack with
            | true -> failwith ""
            | false -> failwith ""))
  in
  failwith ""
