/petr4/ci-test/type-checking/testdata/p4_16_samples/issue774.p4
\n
#include <core.p4>

header Header {
    bit<32> data;
}

parser p0(packet_in p, out Header h) {
    state start {
        p.extract<Header>(_);
        transition next;
    }

    state next {
        p.extract(h);
        transition accept;
    }
}

parser proto(packet_in p, out Header h);
package top(proto p);
top(p0()) main;
************************\n******** petr4 type checking result: ********\n************************\n
