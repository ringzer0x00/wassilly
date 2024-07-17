(module
  (table 2 funcref)
  (elem (i32.const 0) funcref (ref.func $f1) (ref.func $f2))
  (func $f1 (result i32)
    i32.const 42)
  (func $f2 (result i32)
    i32.const 13)
)
