type cont = Command.Language.t
type block_type
type labelcontent = { natcont : cont; brcont : cont; typ : block_type }
type t = BlockLabel of labelcontent | LoopLabel of labelcontent

let block l = BlockLabel l
let loop l = LoopLabel l