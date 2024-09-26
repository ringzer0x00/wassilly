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
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends ocaml dune)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
