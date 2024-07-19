open Datastructures.Monad.DefBot

let monad_destroy_exn m = m >>=? fun a -> a
let monad_destroy_opt m = m >>= fun a -> a
