/petr4/ci-test/type-checking/testdata/p4_16_samples/gauntlet_side_effect_order_3-bmv2.p4
\n
#include <core.p4>
#include <v1model.p4>

header ethernet_t {
    bit<48> dst_addr;
    bit<48> src_addr;
    bit<16> eth_type;
}

header H {
    bit<8> a;
    bit<8> b;
    bit<8> c;
}

struct Headers {
    ethernet_t eth_hdr;
    H h;
}

struct Meta {
    bit<8> tmp;
}

bit<8> do_thing(out bit<8> val) {
    return 8w1;
}


parser p(packet_in pkt, out Headers hdr, inout Meta m, inout standard_metadata_t sm) {
    state start {
        transition parse_hdrs;
    }
    state parse_hdrs {
        pkt.extract(hdr.eth_hdr);
        pkt.extract(hdr.h);
        transition accept;
    }
}

control ingress(inout Headers h, inout Meta m, inout standard_metadata_t sm) {
    bit<8> random_val_0;
    apply {
        random_val_0 = 8w3;
        m.tmp = do_thing(random_val_0);
        h.h.a = do_thing(m.tmp);
    }
}

control vrfy(inout Headers h, inout Meta m) { apply {} }

control update(inout Headers h, inout Meta m) { apply {} }

control egress(inout Headers h, inout Meta m, inout standard_metadata_t sm) { apply {} }

control deparser(packet_out pkt, in Headers h) {
    apply {
        pkt.emit(h);
    }
}
V1Switch(p(), vrfy(), ingress(), egress(), update(), deparser()) main;
************************\n******** petr4 type checking result: ********\n************************\n
