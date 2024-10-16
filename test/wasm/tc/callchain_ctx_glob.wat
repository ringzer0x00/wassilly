(module
  (global $from_wasm (mut i32) (i32.const 10))
  (func (;0;) (result i32)
    global.get 0
    i32.const 5
    i32.add
    call 1
    global.get 0
  )
  (func (;0;) (param i32)
    i32.const 42
    local.get 0
    i32.add
    local.tee 0
    global.set 0
  )
  (table (;0;) 0 funcref)
  (memory (;0;) 1)
  (export "memory" (memory 0))
  (export "fib" (func 0)))
