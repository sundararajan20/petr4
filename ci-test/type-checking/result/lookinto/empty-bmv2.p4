/petr4/ci-test/type-checking/testdata/p4_16_samples/empty-bmv2.p4
\n
#include <core.p4>
#include <v1model.p4>

header hdr {}

struct Headers {}

struct Meta {}

parser p(packet_in b, out Headers h, inout Meta m, inout standard_metadata_t sm) {
    state start {
        transition accept;
    }
}

control vrfy(inout Headers h, inout Meta m) { apply {} }
control update(inout Headers h, inout Meta m) { apply {} }

control egress(inout Headers h, inout Meta m, inout standard_metadata_t sm) { apply {} }

control deparser(packet_out b, in Headers h) {
    apply { b.emit(h); }
}

control ingress(inout Headers h, inout Meta m, inout standard_metadata_t sm) {
    apply { }
}

V1Switch(p(), vrfy(), ingress(), egress(), update(), deparser()) main;
************************\n******** petr4 type checking result: ********\n************************\n
