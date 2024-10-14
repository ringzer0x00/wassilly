(module
  (type (;0;) (func (param i32) (result i32)))
  (type (;1;) (func (param i32 i32) (result i32)))
  (type (;2;) (func (param i32)))
  (type (;3;) (func))
  (type (;4;) (func (result i32)))
  (import "wasi_snapshot_preview1" "args_sizes_get" (func (;0;) (type 1)))
  (import "wasi_snapshot_preview1" "args_get" (func (;1;) (type 1)))
  (import "wasi_snapshot_preview1" "proc_exit" (func (;2;) (type 2)))
  (func (;3;) (type 3)
    nop)
  (func (;4;) (type 0) (param i32) (result i32)
    (local i32)
    global.get 0
    i32.const 16
    i32.sub
    local.tee 1
    global.set 0
    local.get 1
    i32.const 1032
    i32.store offset=8
    local.get 1
    i32.const 1044
    i32.store
    local.get 1
    i32.const 8
    i32.add
    local.get 1
    local.get 0
    select
    local.tee 0
    local.get 0
    i32.load
    i32.load
    call_indirect (type 0)
    local.set 0
    local.get 1
    i32.const 16
    i32.add
    global.set 0
    local.get 0)
  (func (;5;) (type 0) (param i32) (result i32)
    (local i32)
    global.get 0
    i32.const 16
    i32.sub
    local.tee 1
    global.set 0
    local.get 1
    i32.const 1056
    i32.store offset=8
    local.get 1
    i32.const 1068
    i32.store
    local.get 1
    i32.const 8
    i32.add
    local.get 1
    local.get 0
    select
    local.tee 0
    local.get 0
    i32.load
    i32.load
    call_indirect (type 0)
    local.set 0
    local.get 1
    i32.const 16
    i32.add
    global.set 0
    local.get 0)
  (func (;6;) (type 1) (param i32 i32) (result i32)
    local.get 0
    i32.const 1
    i32.gt_s
    local.tee 0
    call 4
    local.get 0
    call 5
    i32.add)
  (func (;7;) (type 0) (param i32) (result i32)
    i32.const 23)
  (func (;8;) (type 0) (param i32) (result i32)
    i32.const 42)
  (func (;9;) (type 0) (param i32) (result i32)
    i32.const 1)
  (func (;10;) (type 0) (param i32) (result i32)
    i32.const 2)
  (func (;11;) (type 3)
    call 3
    call 12
    call 17
    unreachable)
  (func (;12;) (type 4) (result i32)
    call 13)
  (func (;13;) (type 4) (result i32)
    (local i32 i32 i32 i32)
    global.get 0
    i32.const 16
    i32.sub
    local.tee 0
    global.set 0
    block  ;; label = @1
      local.get 0
      local.tee 1
      i32.const 12
      i32.add
      local.get 0
      i32.const 8
      i32.add
      call 0
      i32.eqz
      if  ;; label = @2
        local.get 1
        i32.load offset=12
        local.tee 2
        if (result i32)  ;; label = @3
          local.get 0
          local.get 2
          i32.const 2
          i32.shl
          local.tee 2
          i32.const 19
          i32.add
          i32.const -16
          i32.and
          i32.sub
          local.tee 0
          local.tee 3
          global.set 0
          local.get 3
          local.get 1
          i32.load offset=8
          i32.const 15
          i32.add
          i32.const -16
          i32.and
          i32.sub
          local.tee 3
          global.set 0
          local.get 0
          local.get 2
          i32.add
          i32.const 0
          i32.store
          local.get 0
          local.get 3
          call 1
          br_if 2 (;@1;)
          local.get 1
          i32.load offset=12
        else
          i32.const 0
        end
        local.tee 2
        local.get 0
        call 14
        local.set 0
        local.get 1
        i32.const 16
        i32.add
        global.set 0
        local.get 0
        return
      end
      i32.const 71
      call 2
      unreachable
    end
    i32.const 71
    call 2
    unreachable)
  (func (;14;) (type 1) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    call 6)
  (func (;15;) (type 2) (param i32)
    local.get 0
    call 2
    unreachable)
  (func (;16;) (type 3)
    call 18)
  (func (;17;) (type 2) (param i32)
    call 18
    call 16
    call 18
    local.get 0
    call 15
    unreachable)
  (func (;18;) (type 3)
    nop)
  (func (;19;) (type 4) (result i32)
    global.get 0)
  (func (;20;) (type 2) (param i32)
    local.get 0
    global.set 0)
  (func (;21;) (type 0) (param i32) (result i32)
    (local i32)
    global.get 0
    local.get 0
    i32.sub
    i32.const -16
    i32.and
    local.tee 1
    global.set 0
    local.get 1)
  (func (;22;) (type 4) (result i32)
    i32.const 1072)
  (table (;0;) 6 6 funcref)
  (memory (;0;) 256 256)
  (global (;0;) (mut i32) (i32.const 5243968))
  (export "memory" (memory 0))
  (export "__indirect_function_table" (table 0))
  (export "_start" (func 11))
  ;;(export "__errno_location" (func 22))
  ;;(export "stackSave" (func 19))
  ;;(export "stackRestore" (func 20))
  ;;(export "stackAlloc" (func 21))
  (elem (;0;) (i32.const 1) func 7 8 9 10 3)
  (data (;0;) (i32.const 1032) "\01")
  (data (;1;) (i32.const 1044) "\02")
  (data (;2;) (i32.const 1056) "\03")
  (data (;3;) (i32.const 1068) "\04"))
