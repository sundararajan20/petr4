/petr4/ci-test/type-checking/testdata/p4_16_samples/named-arg.p4
\n
extern void f(in bit<16> x, in bool y);

control c() {
    apply {
        bit<16> xv = 0;
        bool    b  = true;

        f(y = b, x = xv);
    }
}

control empty();
package top(empty _e);

top(c()) main;
************************\n******** petr4 type checking result: ********\n************************\n
