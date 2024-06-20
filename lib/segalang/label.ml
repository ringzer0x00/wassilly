type cont = Command.Language.t
type block_type = Command.Language.arity
type labelcontent = { natcont : cont; brcont : cont; typ : block_type }
type t = BlockLabel of labelcontent | LoopLabel of labelcontent

let block l = BlockLabel l
let loop l = LoopLabel l
let brcont = function BlockLabel lc | LoopLabel lc -> lc.brcont
