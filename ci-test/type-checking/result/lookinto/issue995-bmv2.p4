/petr4/ci-test/type-checking/testdata/p4_16_samples/issue995-bmv2.p4
\n
/*
Copyright 2017 Cisco Systems, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
#include <core.p4>
#include <v1model.p4>

header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}

struct metadata {
    bit<16> transition_taken;
}

struct headers {
    ethernet_t ethernet;
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    state start {
        transition parse_ethernet;
    }
    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.srcAddr, hdr.ethernet.dstAddr) {
            (0x12f_0000                , 0x456             ): a1;
            (0x12f_0000 &&& 0xffff_0000, 0x456             ): a2;
            (0x12f_0000                , 0x456 &&& 0xfff   ): a3;
            (0x12f_0000 &&& 0xffff_0000, 0x456 &&& 0xfff   ): a4;
            default: a5;
        }
    }
    state a1 {
        meta.transition_taken = 1;
        transition accept;
    }
    state a2 {
        meta.transition_taken = 2;
        transition accept;
    }
    state a3 {
        meta.transition_taken = 3;
        transition accept;
    }
    state a4 {
        meta.transition_taken = 4;
        transition accept;
    }
    state a5 {
        meta.transition_taken = 5;
        transition accept;
    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
        hdr.ethernet.etherType = meta.transition_taken;
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
    }
}

control verifyChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

control computeChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

V1Switch(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;
************************\n******** petr4 type checking result: ********\n************************\n
