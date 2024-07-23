(module
  (type (;0;) (func (param i32) (result i32)))
  (func (;0;) (type 0) (param i32) (result i32)

  local.get 0
  i32.const 2
  i32.gt_s ;; [$0 >= 2]
  (if (result i32)
    (then
      i32.const 3
      local.get 0
      br_if 1
    )
    (else
      local.get 0
      local.get 0
      br_if 1
    )
  )
)
(table (;0;) 0 funcref)
(memory (;0;) 1)
(export "memory" (memory 0))
(export "fib" (func 0)))
