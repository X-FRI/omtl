(lang dune 3.0)

(name omtl)

(generate_opam_files true)

(source
 (github muqiuhan/omtl))

(authors "Muqiu Han")

(maintainers "Muqiu Han")

(license MIT)

(documentation https://github.com/muqiuhan/omtl)

(package
 (allow_empty)
 (name omtl)
 (synopsis "An OCaml minimalist testing framework with zero dependencies")
 (description "An OCaml minimalist testing framework with zero dependencies")
 (depends
  (ocaml
   (>= 4.13.1))
  dune)
 (tags
  (testing test "test framework")))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
