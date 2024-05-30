module SK = Datastructures.Liststack

type 'a stack = 'a list
type frame = Frame.t
type context = frame stack
type t = context

let peek : t -> frame = SK.peek
let pop : t -> t = SK.pop
let push : frame -> t -> t = SK.push
let eq : t -> t -> bool = ( = )

(*add map from ctx to call for context sensitivity*)
