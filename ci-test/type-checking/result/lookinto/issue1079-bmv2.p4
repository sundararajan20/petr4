/petr4/ci-test/type-checking/testdata/p4_16_samples/issue1079-bmv2.p4
\n
/* -*- Mode:C; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */
#include <v1model.p4>

header empty {}

struct headers_t {
  empty e;
};

struct cksum_t {
  bit<16> result;
}

struct metadata_t {
  cksum_t cksum;
  bit b;
};

parser EmptyParser(packet_in b, out headers_t headers, inout metadata_t meta,
                   inout standard_metadata_t standard_metadata)
{
  state start {
    /* No explicit reject */
    /* transition reject; */
    transition accept;
  }
}

control EmptyVerifyChecksum(inout headers_t hdr, inout metadata_t meta)
{
  apply {
    verify_checksum(false, {16w0}, meta.cksum.result, HashAlgorithm.csum16);
  }
}

control EmptyIngress(inout headers_t headers, inout metadata_t meta,
                     inout standard_metadata_t standard_metadata)
{
  apply {}
}

control EmptyEgress(inout headers_t hdr,
                    inout metadata_t meta,
                    inout standard_metadata_t standard_metadata)
{
  apply {
    mark_to_drop(standard_metadata);
  }
}

control EmptyComputeChecksum(inout headers_t hdr,
                             inout metadata_t meta)
{
  apply {
    update_checksum(false, {16w0}, meta.cksum.result, HashAlgorithm.csum16);
    update_checksum(hdr.e.isValid(), {16w0}, meta.cksum.result, HashAlgorithm.csum16);
    update_checksum(meta.b == 0, {16w0}, meta.cksum.result, HashAlgorithm.csum16);
  }
}

control EmptyDeparser(packet_out b, in headers_t hdr)
{
  apply {}
}

V1Switch(EmptyParser(),
         EmptyVerifyChecksum(),
         EmptyIngress(),
         EmptyEgress(),
         EmptyComputeChecksum(),
         EmptyDeparser()) main;
************************\n******** petr4 type checking result: ********\n************************\n
