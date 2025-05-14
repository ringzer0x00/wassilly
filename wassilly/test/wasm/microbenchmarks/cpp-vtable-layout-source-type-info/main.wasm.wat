(module
  (type $t0 (func (param i32) (result i32)))
  (type $t1 (func (param i32 i32) (result i32)))
  (type $t2 (func (param i32)))
  (type $t3 (func))
  (type $t4 (func (result i32)))
  (import "wasi_snapshot_preview1" "args_sizes_get" (func $wasi_snapshot_preview1.args_sizes_get (type $t1)))
  (import "wasi_snapshot_preview1" "args_get" (func $wasi_snapshot_preview1.args_get (type $t1)))
  (import "wasi_snapshot_preview1" "proc_exit" (func $wasi_snapshot_preview1.proc_exit (type $t2)))
  (func $f3 (type $t3)
    (nop))
  (func $f4 (type $t0) (param $p0 i32) (result i32)
    (local $l1 i32)
    (global.set $g0
      (local.tee $l1
        (i32.sub
          (global.get $g0)
          (i32.const 16))))
    (i32.store offset=8
      (local.get $l1)
      (i32.const 1032))
    (i32.store
      (local.get $l1)
      (i32.const 1044))
    (local.set $p0
      (call_indirect $__indirect_function_table (type $t0)
        (local.tee $p0
          (select
            (i32.add
              (local.get $l1)
              (i32.const 8))
            (local.get $l1)
            (local.get $p0)))
        (i32.load
          (i32.load
            (local.get $p0)))))
    (global.set $g0
      (i32.add
        (local.get $l1)
        (i32.const 16)))
    (local.get $p0))
  (func $f5 (type $t0) (param $p0 i32) (result i32)
    (local $l1 i32)
    (global.set $g0
      (local.tee $l1
        (i32.sub
          (global.get $g0)
          (i32.const 16))))
    (i32.store offset=8
      (local.get $l1)
      (i32.const 1056))
    (i32.store
      (local.get $l1)
      (i32.const 1068))
    (local.set $p0
      (call_indirect $__indirect_function_table (type $t0)
        (local.tee $p0
          (select
            (i32.add
              (local.get $l1)
              (i32.const 8))
            (local.get $l1)
            (local.get $p0)))
        (i32.load
          (i32.load
            (local.get $p0)))))
    (global.set $g0
      (i32.add
        (local.get $l1)
        (i32.const 16)))
    (local.get $p0))
  (func $f6 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    (i32.add
      (call $f4
        (local.tee $p0
          (i32.gt_s
            (local.get $p0)
            (i32.const 1))))
      (call $f5
        (local.get $p0))))
  (func $f7 (type $t0) (param $p0 i32) (result i32)
    (i32.const 23))
  (func $f8 (type $t0) (param $p0 i32) (result i32)
    (i32.const 42))
  (func $f9 (type $t0) (param $p0 i32) (result i32)
    (i32.const 1))
  (func $f10 (type $t0) (param $p0 i32) (result i32)
    (i32.const 2))
  (func $_start (type $t3)
    (call $f3)
    (call $f17
      (call $f12))
    (unreachable))
  (func $f12 (type $t4) (result i32)
    (call $f13))
  (func $f13 (type $t4) (result i32)
    (local $l0 i32) (local $l1 i32) (local $l2 i32) (local $l3 i32)
    (global.set $g0
      (local.tee $l0
        (i32.sub
          (global.get $g0)
          (i32.const 16))))
    (block $B0
      (if $I1
        (i32.eqz
          (call $wasi_snapshot_preview1.args_sizes_get
            (i32.add
              (local.tee $l1
                (local.get $l0))
              (i32.const 12))
            (i32.add
              (local.get $l0)
              (i32.const 8))))
        (then
          (local.set $l0
            (call $f14
              (local.tee $l2
                (if $I2 (result i32)
                  (local.tee $l2
                    (i32.load offset=12
                      (local.get $l1)))
                  (then
                    (global.set $g0
                      (local.tee $l3
                        (local.tee $l0
                          (i32.sub
                            (local.get $l0)
                            (i32.and
                              (i32.add
                                (local.tee $l2
                                  (i32.shl
                                    (local.get $l2)
                                    (i32.const 2)))
                                (i32.const 19))
                              (i32.const -16))))))
                    (global.set $g0
                      (local.tee $l3
                        (i32.sub
                          (local.get $l3)
                          (i32.and
                            (i32.add
                              (i32.load offset=8
                                (local.get $l1))
                              (i32.const 15))
                            (i32.const -16)))))
                    (i32.store
                      (i32.add
                        (local.get $l0)
                        (local.get $l2))
                      (i32.const 0))
                    (br_if $B0
                      (call $wasi_snapshot_preview1.args_get
                        (local.get $l0)
                        (local.get $l3)))
                    (i32.load offset=12
                      (local.get $l1)))
                  (else
                    (i32.const 0))))
              (local.get $l0)))
          (global.set $g0
            (i32.add
              (local.get $l1)
              (i32.const 16)))
          (return
            (local.get $l0))))
      (call $wasi_snapshot_preview1.proc_exit
        (i32.const 71))
      (unreachable))
    (call $wasi_snapshot_preview1.proc_exit
      (i32.const 71))
    (unreachable))
  (func $f14 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    (call $f6
      (local.get $p0)
      (local.get $p1)))
  (func $f15 (type $t2) (param $p0 i32)
    (call $wasi_snapshot_preview1.proc_exit
      (local.get $p0))
    (unreachable))
  (func $f16 (type $t3)
    (call $f18))
  (func $f17 (type $t2) (param $p0 i32)
    (call $f18)
    (call $f16)
    (call $f18)
    (call $f15
      (local.get $p0))
    (unreachable))
  (func $f18 (type $t3)
    (nop))
  (func $stackSave (type $t4) (result i32)
    (global.get $g0))
  (func $stackRestore (type $t2) (param $p0 i32)
    (global.set $g0
      (local.get $p0)))
  (func $stackAlloc (type $t0) (param $p0 i32) (result i32)
    (local $l1 i32)
    (global.set $g0
      (local.tee $l1
        (i32.and
          (i32.sub
            (global.get $g0)
            (local.get $p0))
          (i32.const -16))))
    (local.get $l1))
  (func $__errno_location (type $t4) (result i32)
    (i32.const 1072))
  (table $__indirect_function_table 6 6 funcref)
  (memory $memory 256 256)
  (global $g0 (mut i32) (i32.const 5243968))
  (export "memory" (memory $memory))
  (export "__indirect_function_table" (table $__indirect_function_table))
  (export "_start" (func $_start))
  (export "__errno_location" (func $__errno_location))
  (export "stackSave" (func $stackSave))
  (export "stackRestore" (func $stackRestore))
  (export "stackAlloc" (func $stackAlloc))
  (elem $e0 (i32.const 1) func $f7 $f8 $f9 $f10 $f3)
  (data $d0 (i32.const 1032) "\01")
  (data $d1 (i32.const 1044) "\02")
  (data $d2 (i32.const 1056) "\03")
  (data $d3 (i32.const 1068) "\04"))
