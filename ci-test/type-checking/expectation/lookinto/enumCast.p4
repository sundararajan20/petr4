/petr4/ci-test/type-checking/testdata/p4_16_samples/enumCast.p4
\n
#include <core.p4>

enum bit<32> X {
    Zero = 0,
    One = 1
}

enum bit<8> E1 {
   e1 = 0, e2 = 1, e3 = 2
}

enum bit<8> E2 {
   e1 = 10, e2 = 11, e3 = 12
}

header B {
    X x;
}

header Opt {
    bit<16> b;
}

struct O {
    B b;
    Opt opt;
}

parser p(packet_in packet, out O o) {
    state start {
        X x = (X)0;
        bit<32> z = (bit<32>)X.One;
        bit<32> z1 = X.One;
        bool bb;

        E1 a = E1.e1;
        E2 b = E2.e2;

        bb = (a == b);
        bb = bb && (a == 0);
        bb = bb && (b == 0);

        a = (E1) b; // OK
        a = (E1)(E1.e1 + 1); // Final explicit casting makes the assinment legal
        a = (E1)(E2.e1 + E2.e2); //  Final explicit casting makes the assignment legal

        packet.extract(o.b);
        transition select (o.b.x) {
            X.Zero &&& 0x01: accept;
            default: getopt;
        }
    }

    state getopt {
        packet.extract(o.opt);
        transition accept;
    }
}

parser proto<T>(packet_in p, out T t);
package top<T>(proto<T> _p);
top(p()) main;
************************\n******** petr4 type checking result: ********\n************************\n
Uncaught exception:
  
  ("illegal explicit cast" (old_type Integer)
   (new_type
    (Enum ((name X) (typ ((Bit ((width 32))))) (members (Zero One))))))

Raised at Base__Error.raise in file "src/error.ml" (inlined), line 8, characters 14-30
Called from Base__Error.raise_s in file "src/error.ml", line 9, characters 19-40
Called from Petr4__Checker.type_expression in file "lib/checker.ml", line 866, characters 7-33
Called from Petr4__Checker.cast_expression in file "lib/checker.ml", line 923, characters 21-60
Called from Petr4__Checker.type_variable in file "lib/checker.ml", line 3254, characters 24-71
Called from Petr4__Checker.type_declaration_statement in file "lib/checker.ml", line 2890, characters 28-81
Called from Petr4__Checker.type_statement in file "lib/checker.ml", line 2671, characters 7-46
Called from Petr4__Checker.type_statements.fold in file "lib/checker.ml", line 2782, characters 26-58
Called from Stdlib__list.fold_left in file "list.ml", line 121, characters 24-34
Called from Petr4__Checker.type_parser_state in file "lib/checker.ml", line 3021, characters 30-84
Called from Base__List.count_map in file "src/list.ml", line 390, characters 13-17
Called from Base__List.map in file "src/list.ml" (inlined), line 418, characters 15-31
Called from Petr4__Checker.type_parser in file "lib/checker.ml", line 3059, characters 21-76
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
