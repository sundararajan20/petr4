/petr4/ci-test/type-checking/testdata/p4_16_samples/generic-struct-tuple.p4
\n
struct S<T> {
    tuple<T, T> t;
}

const S<bit<32>> x = { t = { 0, 0 } };************************\n******** petr4 type checking result: ********\n************************\n
File /petr4/ci-test/type-checking/testdata/p4_16_samples/generic-struct-tuple.p4, line 1, characters 8-9: syntax error
************************\n******** p4c type checking result: ********\n************************\n
[--Wwarn=missing] warning: Program does not contain a `main' module
