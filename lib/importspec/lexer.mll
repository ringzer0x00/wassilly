{
open Lexing
open Parser
}

let white = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"
let string = [^ '[' ']' ';' '(' ')' '\\' '.' '#' ' ' '\t' '\n' '\t']+
let digit = ['0'-'9']+
let sign = ['-' '+']
let float_constant = sign? digit+ '.' digit+

rule read =
  parse
    | white { read lexbuf }
    | newline { END }
    | "id" { IDENTITY }
    | "glob" { GLOB }
    | "table" { TABLE }
    | "memory" { MEM }
    | "funcref" { FUNCREF }
    | "externref" { EXTERNREF }
    | "func" { FUNC }
    | "calls" { CALL }
    | "unspec" { UNSPEC }
    | "effect" { EFFECT }
    | "postinst" { POST_INST }
    | "#" { skip_line lexbuf }
    | "i32" { I32 }
    | "i64" { F64 }
    | "f32" { F32 }
    | "f64" { F64 }
    | "[" { SQ_LEFT_BR }
    | "]" { SQ_RIGHT_BR }
    | "(" { LPAR }
    | ")" { RPAR }
    | "{" { C_LEFT }
    | "}" { C_RIGHT }
    | ";" { SEMICOLON }
    | "->" { RARROW }
    | "=>" { IMPLIES }
    | "TOP" { TOP }
    | "BOT" { BOT }
    | "PINF" {PINF}
    | "NINF" {NINF} 
    | "param" { PARAM }
    | "else" { ELSE }
    | "when" { WHEN }
    | digit {INT_LIT (int_of_string (lexeme lexbuf))}
    | float_constant {FLOAT_LIT (float_of_string (lexeme lexbuf))}
    | string { ID (lexeme lexbuf) }
    | eof { EOF }
    | _ as c { failwith (Printf.sprintf "unexpected character: %C" c) }
and skip_line =
  parse
    | newline { new_line lexbuf; read lexbuf }
    | eof { EOF }
    | _ { skip_line lexbuf }