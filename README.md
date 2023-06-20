[![Build Status](https://travis-ci.org/cornell-netlab/petr4.svg?branch=use-poulet4)](https://travis-ci.org/cornell-netlab/petr4)

# Petr4
The Petr4 project is developing the formal semantics of the [P4
Language](https://p4.org) backed by an independent reference implementation.

# POPL'21 artifact
See https://verified-network-toolchain.github.io/petr4/ or check out the `gh-pages` branch
for information on the Petr4 artifact.

# Getting Started

## Installing Petr4

1. Install OPAM 2 following the official [OPAM installation
   instructions](https://opam.ocaml.org/doc/Install.html). Make sure `opam
   --version` reports version 2 or later.

1. (on Linux) Install external dependencies:
   ```
   sudo apt-get install m4 libgmp-dev
   ```

1. (on MacOS) Install external dependencies:
   ```
   brew install m4
   brew install gmp
   ```

### Installing from source
You can use the [scripts](https://github.com/verified-network-toolchain/petr4/tree/main/.github/scripts) to install Petr4. 
Alternatively, follow theses steps:
1. Check the installed version of OCaml:
    ```
    ocamlc -v
    ```
    If the version is less than 4.14.0, upgrade:
    ```
    opam switch create <name> ocaml-base-compiler.4.14.0
    ```

1. Install [p4pp](https://github.com/cornell-netlab/p4pp) from source.
   ```
   opam pin add p4pp https://github.com/cornell-netlab/p4pp.git
   ```

1. Install Coq and Bignum.
   ```
   opam install coq
   opam install bignum
   ```
   If this doesn't work, install the dependencies manually. This step shouldn't be needed.
   ```
   opam install ANSITerminal alcotest bignum cstruct-sexp pp ppx_deriving ppx_deriving_yojson yojson js_of_ocaml js_of_ocaml-lwt js_of_ocaml-ppx
   ```

1. Build bundled dependencies.
   ```
   opam repo add coq-released https://coq.inria.fr/opam/released
   opam pin add coq-vst-zlist https://github.com/PrincetonUniversity/VST.git
   opam install . --deps-only
   ```

1. Use dune to build and install petr4.
   ```
   dune build
   dune install
   ```

1. [Optional] Run tests
   ``` 
   make test
   ```

1. [Optional] Install `utop`
   ```
   opam install utop
   ```

1. [Optional] Run one of the following commands `dune utop` OR
   `dune utop -p petr4`. Check if you can run the following command
   in the toplevel. It should return an empty string.
   ```
   Petr4.P4info.to_string Petr4.P4info.dummy;;   
   ```

## Running Petr4

Currently `petr4` is merely a P4 front-end. By default, it will parse
a source program to an abstract syntax tree and print it out, either
as P4 or encoded into JSON.

Run `petr4 -help` to see the list of currently-supported options.

# Contributing

Petr4 is an open-source project. We encourage contributions!
Please file issues on
[Github](https://github.com/cornell-netlab/petr4/issues).

# Credits

See the list of [contributors](CONTRIBUTORS).

# License

Petr4 is released under the [Apache2 License](LICENSE).
