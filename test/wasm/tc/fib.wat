(module
  (type (;0;) (func (param i32) (result i32)))
  (global $from_wasm i32 (i32.const 10))
  (func (;0;) (type 0) (param i32) (result i32)
    local.get 0
    i32.eqz
    (if (result i32)
      (then
        i32.const 0
      )
      (else
        local.get 0
        i32.const 1
        i32.eq
        (if (result i32)
          (then 
            i32.const 1
          )
          (else
            local.get 0
            i32.const 1
            i32.sub
            call 0
            local.get 0
            i32.const 2
            i32.sub
            call 0
            i32.add
          )
        )
      )
    )
  )
(table (;0;) 0 funcref)
(memory (;0;) 1)
(export "memory" (memory 0))
(export "fib" (func 0)))
