%{
open Term
%}

%token <string> ID
%token <int> INT_LIT
%token <float> FLOAT_LIT
%token <int32> INT32_LIT

%token I32 "i32"
%token I64 "i64"
%token F32 "f32"
%token F64 "f64"

%token SQ_LEFT_BR "["
%token SQ_RIGHT_BR "]"
%token LPAR "("
%token RPAR ")"
%token C_LEFT "{"
%token C_RIGHT "}"
%token SEMICOLON ";"

%token PINF "PINF"
%token NINF "NINF"

%token RARROW "->"
%token TOP "TOP"
%token BOT "BOT"

%token EFFECT "effect"

%token GLOB "glob"
%token TABLE "table"
%token MEM "memory"
%token CALL "calls"
%token EXTERNREF "externref"
%token FUNCREF "funcref"
%token PARAM "param"
%token FUNC "func"
%token IMPLIES "=>"
%token ELSE "else"
%token WHEN "when"
%token UNSPEC "unspec"


%token END
%token EOF

%start <Term.program> program
%%

let break := | END | EOF

let program:=
  | EOF; {Program []}
  | t=term; break; tl=term*; EOF; { concat t tl }

let wasmtype_integer :=
  | I32; { I32Type }
  | I64; { I64Type }

let wasmtype_float :=
  | F32; { F32Type }
  | F64; { F64Type }

let wasmvaluetype := wasmtype_integer | wasmtype_float

let lit_integer := SQ_LEFT_BR; nl=INT_LIT; SEMICOLON; nr=INT_LIT; SQ_RIGHT_BR; 
  {Num (I.of_scalar (I.int_scalar nl) (I.int_scalar nr))}
let lit_float := SQ_LEFT_BR; nl=FLOAT_LIT; SEMICOLON;  nr=FLOAT_LIT; SQ_RIGHT_BR; 
  {Num (I.of_scalar (I.float_scalar nl) (I.float_scalar nr))}

let glob := 
  | GLOB; x=ID; t=wasmtype_integer; nv=lit_integer; { Glob (x,t,nv) }
  | GLOB; x=ID; t=wasmtype_float; nv=lit_float; { Glob (x,t,nv) }

let tabletype :=
  | FUNCREF; { Funcref }
  | EXTERNREF; { Externref }

let param :=
  | PARAM; t=wasmvaluetype; x=ID; { Param (t,x) }

let res :=
  | t=wasmvaluetype; { ResultType (t) }

let value :=
  | SQ_LEFT_BR; l=scalarparse; SEMICOLON; r=scalarparse; SQ_RIGHT_BR; {Num (I.of_scalar l r)}
  | r=ID; { Rel(r) }


let tablebinding :=
  | LPAR; l=INT_LIT; RARROW; r=INT_LIT; RPAR; SEMICOLON; { TableBinding (Int32.of_int l, Int32.of_int r) }

let unspec := | UNSPEC; TOP; {Top} | UNSPEC; BOT; {Bot} | {Top}

let table :=
  | TABLE; x=ID; tt=tabletype; SQ_LEFT_BR; tb=tablebinding*; SQ_RIGHT_BR; u=unspec; { Table (x,tt,tb, u) }

let signature :=
  | SQ_LEFT_BR; ps=param*; SQ_RIGHT_BR; RARROW; SQ_LEFT_BR; rs=res*; SQ_RIGHT_BR; {FuncSig (ps, rs)}

let scalarparse :=
  | x=INT_LIT; {I.int_scalar x}
  | x=FLOAT_LIT; {I.float_scalar x}
  | PINF; {I.inf_scalar (1)}
  | NINF; {I.inf_scalar (-1)}

let typedresult :=
  | t=wasmvaluetype; v=value; { Result (t, v) } 

let assignment := | EFFECT; GLOB; x=INT_LIT; t=wasmvaluetype; v=value; {GlobAss ((Int32.of_int x),t,v)} 
                  | EFFECT; MEM; m=ID; fr=INT32_LIT; to_=INT32_LIT; s=INT_LIT; v=value; t=wasmvaluetype; {MemAss (m,fr,to_,s,v,t)}
                  | EFFECT; TABLE; x=ID; b=tablebinding; {TableAss(x,b)}

let call := | CALL; x=ID; {Calls x}

let postcondition :=
  | r=typedresult*; a=assignment*; c=call*; { r, a, c }

let precondition :=
  | x=ID; { x }

let implication :=
  | WHEN; p=precondition*; IMPLIES; C_LEFT; x=postcondition; C_RIGHT; ELSE; C_LEFT; e=implication; C_RIGHT; {Implication (p,x,e)}
  | x=postcondition; {Implies (x)}

let func :=
  | FUNC; x=ID; LPAR; s=signature; RPAR; i=implication; {Func (x, s, i)}

let term :=
  | glob
  | table
  | func
