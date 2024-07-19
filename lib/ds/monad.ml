module DefBot = struct
  exception UndefinedDefBot

  type 'a t = Def of 'a | Bot

  let return x = Def x
  let bind x op = match x with Bot -> Bot | Def a -> op a
  let ( >>= ) = bind
  let compose f g x = f x >>= fun y -> g y
  let ( >=> ) = compose
  let map x f = x >>= fun d -> f d

  let bind_exn x op =
    match x with Bot -> raise UndefinedDefBot | Def a -> op a

  let ( >>=? ) = bind_exn
end

module Writer = struct
  type 'a t = 'a * string

  let return x = (x, "")

  let ( >>= ) m f =
    let x, s1 = m in
    let y, s2 = f x in
    (y, s1 ^ s2)
end
