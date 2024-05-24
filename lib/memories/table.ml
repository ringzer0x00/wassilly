type t

let set = failwith "(table.set table (pos expression) (val expression))"
let get = failwith "(table.get table (pos expression))"

(*

(Updated for Wasm 2.0 in in 2022)

In the text format, a table is declared with its table type, i.e., (initial) size and element type -- 
currently funcref and externref are the only supported types:

(table $name 100 funcref)

Since Wasm 2.0, there can be multiple tables in a module.

A table can be initialised within a module by providing one or more active element segments:

(elem (i32.const 0) $f1 $f2 $f3)

where the expression denotes the offset and is followed by a list of functions defined in the module.

Since Wasm 2.0, tables can furhter be accessed and modified through instructions like table.get, table.set, table.size, table.grow, etc.

Before 2.0, the only way to use a table was through the call_indirect instruction:

(call_indirect (type $t) (arg1) ... (argn) (index))

You can find a few simple examples in the Wasm spec test suite, e.g. here:

    https://github.com/WebAssembly/spec/blob/master/test/core/table.wast
    https://github.com/WebAssembly/spec/blob/master/test/core/elem.wast
    https://github.com/WebAssembly/spec/blob/master/test/core/table_get.wast
    https://github.com/WebAssembly/spec/blob/master/test/core/table_set.wast

A table does not have columns. As for execution, out of bounds access causes a trap, as does accessing an uninitialised index or a type mismatch.

*)
