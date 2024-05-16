module type I = Inputoutput.InterpreterInput

module type S = sig
  type e
  type t

  val in_domain : e -> t -> e option
  val add : e -> t -> t
  val widen : t -> e -> t * e
end

module Stack (I : I) : S = struct
  module S = Set.Make (I)

  type e = I.t
  type t = S.t

  (*let in_domain elem stack = S.exists (I.pred elem) stack*)

  let in_domain elem stack = S.find_first_opt (fun x -> I.pred elem x) stack
  let add e s = S.add e s

  let widen sk c1 =
    match in_domain c1 sk with
    | None -> (add c1 sk, c1)
    | Some c2 -> (
        let env1, env2 = (I.env_of_i c1, I.env_of_i c2) in
        match I.env_leq env1 env2 with
        | true -> (sk, c2)
        | false ->
            let eW = I.env_widen env2 env1 in
            let cW = (eW, I.expr_of_i c2) in
            let sk' = S.remove c2 sk in
            (add cW sk', cW))
end
