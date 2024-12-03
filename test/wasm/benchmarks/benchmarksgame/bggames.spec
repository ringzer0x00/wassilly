func proc_exit ([param i32 x] -> []) id
func fd_close ([param i32 x] -> [i32]) i32 [NINF;PINF]
func fd_seek ([param i32 a param i64 b param i32 c param i32 d] -> [i32]) i32 [NINF;PINF]
func fd_write ([param i32 a param i32 b param i32 c param i32 d] -> [i32]) i32 [NINF;PINF]
func fd_fdstat_get ([param i32 a param i32 b param i32 c] -> []) id
func fd_read ([param i32 a param i32 b param i32 c param i32 d] -> [i32]) i32 [NINF;PINF]
