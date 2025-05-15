type cont = Language.Command.Command.t
type block_type = Language.Typing.block_type

type labelcontent = {
  natcont : cont;
  brcont : cont;
  typ : block_type;
  cmd : cont;
}

and label = BlockLabel of labelcontent | LoopLabel of labelcontent

let gettype (mod_ : Instance.instance) idx =
  let t = List.nth mod_.types idx in
  t.it

let type_of_peeked_label = function BlockLabel c | LoopLabel c -> c.typ
let cmd_of_lab = function BlockLabel l -> l.cmd | LoopLabel l -> l.cmd

let extract_type_of_label _mod_ (t : block_type) =
  match t with
  | Wasm.Ast.VarBlockType _var -> (
      let _t = gettype _mod_ (Int32.to_int _var.it) in
      match _t with FuncType (i, o) -> (i, o))
  | Wasm.Ast.ValBlockType vt -> (
      match vt with Some t -> ([], [ t ]) | None -> ([], []))

let print_label = function BlockLabel _ -> "Block" | LoopLabel _ -> "Loop"
(*
let peek_nth nth l = List.nth_opt l nth
let pop_n : int -> t -> t = SK.pop_n
let push x s : t = x :: s
let block l = BlockLabel l
let loop l = LoopLabel l
let is_empty = function [] -> true | _ -> false
*)
