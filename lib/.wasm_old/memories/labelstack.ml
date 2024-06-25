module SK = Datastructures.Liststack

type cont = Language.Command.Command.t
type block_type = Language.Typing.block_type

type labelcontent = {
  natcont : cont;
  brcont : cont;
  typ : block_type;
  cmd : cont;
}

and label = BlockLabel of labelcontent | LoopLabel of labelcontent
(*type? idk*)

(*a label containts:
   - type of output
   - natural continuation
   - br continuation i.e.: loops are different from blocks when targeted by br instrs*)
type 'a stack = 'a SK.stack
type t = label stack

let peek_nth nth l = List.nth_opt l nth
let pop_n : int -> t -> t = SK.pop_n
let push x s : t = x :: s
let block l = BlockLabel l
let loop l = LoopLabel l
let is_empty = function [] -> true | _ -> false
