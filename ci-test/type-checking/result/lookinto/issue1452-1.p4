/petr4/ci-test/type-checking/testdata/p4_16_samples/issue1452-1.p4
\n
control c() {
    bit<32> x;

    action b(out bit<32> arg) {
        arg = 2;
    }

    apply {
        b(x);
    }
}

control proto();
package top(proto p);

top(c()) main;
************************\n******** petr4 type checking result: ********\n************************\n
