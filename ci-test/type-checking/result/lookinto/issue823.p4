/petr4/ci-test/type-checking/testdata/p4_16_samples/issue823.p4
\n
#include <core.p4>

// Architecture
parser P<H>(packet_in pkt, out H hdr);
control C();
package S<H>(P<H> p, C c);

// User Program
header data_h {
    bit<32> da;
}

struct headers_t {
    data_h data;
}

parser MyP2(packet_in pkt, out headers_t hdr) {
    state start {
        transition reject;
    }
}

parser MyP1(packet_in pkt, out headers_t hdr) {
    MyP2() subp;
    state start {
        subp.apply(pkt, hdr);
        transition accept;
    }
}

control MyC1() {
    apply {
    }
}

S(MyP1(), MyC1()) main;
************************\n******** petr4 type checking result: ********\n************************\n
