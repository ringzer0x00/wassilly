module AT = Apronext.Texprext

type expr = AT.t

let of_interval e i = AT.cst e (Apron.Coeff.Interval i)
let of_interval_in_ad (ad : Aprondomain.dom) i = of_interval ad.env i
