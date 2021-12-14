#!/bin/bash

# petr4 build script for macos

set -e  # Exit on error.
set -x  # Make command execution verbose

export PETR4_DEPS="m4 \
                   gmp"

pwd
# install dependencies
brew update
brew install \
  ${PETR4_DEPS}
opam update
opam upgrade
# install p4pp
#opam switch 4.09.1
opam pin add p4pp https://github.com/cornell-netlab/p4pp.git
eval $(opam env)
#install dune
#opam install dune
#export PATH="/usr/local/opt/dune/bin:$PATH"
#cd ../..
#dune external-lib-deps --missing @install
# install dependencies for petr4
opam install ANSITerminal alcotest bignum cstruct-sexp pp ppx_deriving ppx_deriving_yojson yojson js_of_ocaml js_of_ocaml-lwt js_of_ocaml-ppx
#dune external-lib-deps --missing @@default

pwd

# install deps for poulet4
opam pin add coq $NEW_VERSION
opam repo add coq-released https://coq.inria.fr/opam/released
opam install coq-equations coq-record-update coq-compcert 
# install deps for poulet4_ccomp
opam install zarith
make
make install

