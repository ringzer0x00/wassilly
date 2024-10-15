(module
  (func (;0;) (param i32) (result i32)
    local.get 0
    call 1
  )
  (func (;0;) (param i32) (result i32)
    i32.const 42
    local.tee 0
  )
  (table (;0;) 0 funcref)
  (memory (;0;) 1)
  (export "memory" (memory 0))
  (export "fib" (func 0)))
