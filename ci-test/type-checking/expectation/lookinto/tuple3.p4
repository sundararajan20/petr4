/petr4/ci-test/type-checking/testdata/p4_16_samples/tuple3.p4
\n
const tuple<bit<32>, bit<32>> t = { 0, 1 };
const bit<32> f = t[0];
************************\n******** petr4 type checking result: ********\n************************\n
Uncaught exception:
  
  (lib/error.ml.Type
   ((I
     (filename /petr4/ci-test/type-checking/testdata/p4_16_samples/tuple3.p4)
     (line_start 2) (line_end ()) (col_start 18) (col_end 19))
    (Mismatch (expected array)
     (found (Tuple ((types ((Bit ((width 32))) (Bit ((width 32)))))))))))

Raised at Petr4__Error.raise_mismatch in file "lib/error.ml", line 37, characters 2-26
Called from Petr4__Checker.type_array_access in file "lib/checker.ml", line 1441, characters 20-57
Called from Petr4__Checker.type_expression in file "lib/checker.ml", line 854, characters 7-44
Called from Petr4__Checker.cast_expression in file "lib/checker.ml", line 941, characters 21-60
Called from Petr4__Checker.type_constant in file "lib/checker.ml", line 2905, characters 19-65
Called from Petr4__Checker.type_declarations.f in file "lib/checker.ml", line 4118, characters 26-55
Called from Stdlib__list.fold_left in file "list.ml", line 121, characters 24-34
Called from Base__List0.fold in file "src/list0.ml" (inlined), line 21, characters 22-52
Called from Petr4__Checker.type_declarations in file "lib/checker.ml", line 4121, characters 19-58
Called from Petr4__Checker.check_program in file "lib/checker.ml", line 4128, characters 18-78
Called from Petr4__Common.Make_parse.check_file' in file "lib/common.ml", line 95, characters 17-51
Called from Petr4__Common.Make_parse.check_file in file "lib/common.ml", line 108, characters 10-50
Called from Main.check_command.(fun) in file "bin/main.ml", line 70, characters 14-65
Called from Core_kernel__Command.For_unix.run.(fun) in file "src/command.ml", line 2453, characters 8-238
Called from Base__Exn.handle_uncaught_aux in file "src/exn.ml", line 111, characters 6-10
************************\n******** p4c type checking result: ********\n************************\n
[--Wwarn=missing] warning: Program does not contain a `main' module
