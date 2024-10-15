(module
  (type (;0;) (func (param i32) (result i32)))
  (global $from_wasm i32 (i32.const 10))
  (func (;0;) (type 0) (param i32) (result i32)
    i32.const 0
    local.tee 0
  )
  (table (;0;) 0 funcref)
  (memory (;0;) 1)
  (export "memory" (memory 0))
  (export "fib" (func 0)))
