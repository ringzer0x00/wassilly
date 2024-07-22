type cont = Language.Command.Command.t
type block_type = Language.Typing.block_type

type labelcontent = {
  natcont : cont;
  brcont : cont;
  typ : block_type;
  cmd : cont;
}

and label = BlockLabel of labelcontent | LoopLabel of labelcontent

let type_of_peeked_label = function BlockLabel c | LoopLabel c -> c.typ

let extract_type_of_label _mod_ (t : block_type) =
  match t with
  | Wasm.Ast.VarBlockType _var -> failwith "for now ok"
  | Wasm.Ast.ValBlockType vt -> (
      match vt with Some t -> ([], [ t ]) | None -> ([], []))

(*
let peek_nth nth l = List.nth_opt l nth
let pop_n : int -> t -> t = SK.pop_n
let push x s : t = x :: s
let block l = BlockLabel l
let loop l = LoopLabel l
let is_empty = function [] -> true | _ -> false
*)
