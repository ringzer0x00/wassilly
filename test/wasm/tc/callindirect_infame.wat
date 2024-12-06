(module
  (table 3 funcref)
  (elem (i32.const 0) funcref (ref.func $entry) (ref.func $f1) (ref.func $f2))
  (func $f1 (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.store
    local.get 0
    i32.const 1
    i32.add
    local.get 1
    local.get 0
    call_indirect (param i32 i32) (result i32)
  )
  (func $f2 (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.store
    local.get 0
    i32.const 1
    i32.add
    local.get 1
    local.get 0
    call_indirect (param i32 i32) (result i32)
  )
  (func $entry (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.store
    local.get 0
    i32.const 1
    i32.add
    local.get 1
    local.get 0
    call_indirect (param i32 i32) (result i32)
  )
  (memory $memory 1)
  (export "entry" (func 2))
  (export "f1" (func 0))
  (export "f2" (func 1))
)
