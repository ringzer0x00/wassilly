type funcs
type call
type stack
type cache
type result
type partial_result
type scg

val eval :
  funcs -> call -> stack -> cache -> partial_result -> result * cache * scg
