/petr4/ci-test/type-checking/testdata/p4_16_samples/issue2151.p4
\n
control c() {
    bit<16> f = 0;
    bit<128> y = 0;
    action a() {
        y = (bit<128>)f;
    }
    apply {
        exit; // the exit comes before the action call
        a();
    }

}

control e();
package top(e e);

top(c()) main;
************************\n******** petr4 type checking result: ********\n************************\n
