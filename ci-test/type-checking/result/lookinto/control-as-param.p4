/petr4/ci-test/type-checking/testdata/p4_16_samples/control-as-param.p4
\n
#include <core.p4>

control E(out bit b);

control D(out bit b) {
    apply {
        b = 1;
    }
}

control F(out bit b) {
    apply {
        b = 0;
    }
}

control C(out bit b)(E d) {
    apply {
        d.apply(b);
    }
}

control Ingress(out bit b) {
    D() d;
    F() f;
    C(d) c0;
    C(f) c1;
    apply {
        c0.apply(b);
        c1.apply(b);
    }
}

package top(E _e);

top(Ingress()) main;
************************\n******** petr4 type checking result: ********\n************************\n
