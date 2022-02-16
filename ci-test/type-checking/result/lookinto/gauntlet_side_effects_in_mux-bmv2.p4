/petr4/ci-test/type-checking/testdata/p4_16_samples/gauntlet_side_effects_in_mux-bmv2.p4
\n
#include <core.p4>
#include <v1model.p4>

header ethernet_t {
    bit<48> dst_addr;
    bit<48> src_addr;
    bit<16> eth_type;
}

header H {
    bit<8>  a;
    bit<8>  b;
}

struct Headers {
    ethernet_t eth_hdr;
    H     h;
}

struct Meta {}

bit<16> reset(out bit<8> hPSe) {
    return 16w2;
}

parser p(packet_in pkt, out Headers hdr, inout Meta m, inout standard_metadata_t sm) {
    state start {
        pkt.extract(hdr.eth_hdr);
        pkt.extract(hdr.h);
        transition accept;
    }
}

control ingress(inout Headers h, inout Meta m, inout standard_metadata_t sm) {
    apply {
        h.eth_hdr.eth_type = (h.eth_hdr.src_addr == 5) ? reset(h.h.a) : reset(h.h.b);
    }
}

control vrfy(inout Headers h, inout Meta m) { apply {} }

control update(inout Headers h, inout Meta m) { apply {} }

control egress(inout Headers h, inout Meta m, inout standard_metadata_t sm) { apply {} }

control deparser(packet_out b, in Headers h) { apply { b.emit(h); } }

V1Switch(p(), vrfy(), ingress(), egress(), update(), deparser()) main;

************************\n******** petr4 type checking result: ********\n************************\n
