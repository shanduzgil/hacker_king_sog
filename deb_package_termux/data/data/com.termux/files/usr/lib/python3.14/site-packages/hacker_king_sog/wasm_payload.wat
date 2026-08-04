(module
  (func $steal_cookie (export "steal")
    (call $log (i32.const 0))
  )
  (func $log (param $p i32)
    (i32.store (i32.const 0) (i32.const 0x41414141))
  )
  (memory (export "memory") 1)
)
