/petr4/ci-test/type-checking/testdata/p4_16_samples/serenum-int.p4
\n
#include <core.p4>

enum int<24> EthTypes {
    IPv4 = 0x0800,
    ARP = 0x0806,
    RARP = 0x8035,
    EtherTalk = 0x809B,
    VLAN = 0x8100,
    IPX = 0x8137,
    IPv6 = 0x86DD
}

header Ethernet {
    bit<48> src;
    bit<48> dest;
    EthTypes type;
}

struct Headers {
    Ethernet eth;
}

parser prs(packet_in p, out Headers h) {
    Ethernet e;

    state start {
        p.extract(e);
        transition select(e.type) {
            EthTypes.IPv4: accept;
            EthTypes.ARP: accept;
            default: reject;
        }
    }
}

control c(inout Headers h) {
    apply {
        if (!h.eth.isValid())
            return;
        if (h.eth.type == EthTypes.IPv4)
            h.eth.setInvalid();
        else
            h.eth.type = (EthTypes)(int<24>)0;
    }
}

parser p<H>(packet_in _p, out H h);
control ctr<H>(inout H h);
package top<H>(p<H> _p, ctr<H> _c);

top(prs(), c()) main;
************************\n******** petr4 type checking result: ********\n************************\n
