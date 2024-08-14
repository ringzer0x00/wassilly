(module
  (func (;0;) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.or
  )
  (table (;0;) 0 funcref)
  (memory (;0;) 1)
  (export "memory" (memory 0))
  (export "fib" (func 0)))
