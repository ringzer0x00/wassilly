(lang dune 3.12)

(using menhir 2.1)

(name wassilly)

(generate_opam_files true)

(source
 (github ringzer0x00/wassilly))

(authors "Mattia Paccamiccio")

(maintainers "Mattia Paccamiccio")

(license LICENSE)

(documentation https://there/is/no/documentation)

(package
 (name wassilly)
 (synopsis "wassilly")
 (description "Call graph extraction for the WebAssembly language.")
 (depends
  ocaml
  dune
  wasm
  (apron
   (< 0.9.15))
  (apronext (= 1.0.4))
  stdio
  ppx_inline_test
  ppx_deriving
  ppx_show
  ocamlgraph
  ounit2
  menhir
  )
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
