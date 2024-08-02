open Segalang
open Command

let body : Language.t =
  [
    Language.Block
      ( 1,
        [
          Language.Val 0l;
          Language.If
            ( 1,
              [
                Language.Block
                  (1, [ Language.Val (-1l); Language.Val 3l; Language.Mul ]);
              ],
              [ Language.Block (1, [ Language.Val 8l ]) ] );
        ] );
  ]

let funs = Funcs.add "silly" ([], body) Funcs.empty
let mem = Memory.empty
let call = (Memory.empty, body)
let output = Apron.Interval.of_int (-3) 8
let pres : Eval.partial_result = { br = Labelmap.empty; return = Memory.Bot }

let result, _, _ =
  Eval.fixpoint funs (call, true) Stack.empty Cache.empty pres Eval.eval

let bind_result x f = match x with Result.Bot -> false | Result.Def o -> f o
let ( >>= ) = bind_result
let bind_mem x f = match x with Memory.Bot -> false | Memory.Def o -> f o
let ( >>=^ ) = bind_mem

let assertion =
  result >>= fun d ->
  d.nat >>=^ fun m ->
  match m.opsk with
  | [] -> false
  | _h :: [] -> Apronext.Intervalext.equal _h output
  | _h :: _ -> false
