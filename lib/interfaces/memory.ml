module type SomeMemory = sig
  type allocation (*identifier*)
  type value

  (*internal representation of type within memory (ex: REAL,INT for Apron)*)
  type valuetype
  type typedalloc = valuetype * allocation
  type expression
  type mem

  val read : allocation -> mem -> value
  val assign : typedalloc -> expression -> mem -> mem
  val write : typedalloc -> value -> mem -> mem
end
