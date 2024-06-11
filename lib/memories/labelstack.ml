module SK = Datastructures.Liststack

type cont = Language.Command.Command.t
type block_type = Language.Typing.block_type

type labelcontent = { natcont : cont; brcont : cont; typ : block_type }
and label = Block of labelcontent | Loop of labelcontent
(*type? idk*)

(*a label containts:
   - type of output
   - natural continuation
   - br continuation i.e.: loops are different from blocks when targeted by br instrs*)
type 'a stack = 'a SK.stack
type t = label stack

let peek_nth : t -> int -> label = List.nth
let pop_n : int -> t -> t = SK.pop_n
let push x s : t = x :: s
let block l = Block l
let loop l = Loop l
