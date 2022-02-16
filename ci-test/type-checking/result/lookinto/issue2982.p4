/petr4/ci-test/type-checking/testdata/p4_16_samples/issue2982.p4
\n
control ComputeChecksum<H>(inout H hdr);

extern void update_checksum_with_payload<T, O>(in T data, out O ck);

struct flags {
    bit<1>  cwr;
}

header tcp {
    flags flags;
    bit<16> checksum;
}

struct headers {
    tcp tcp;
}

control computeChecksum(inout headers hdr) {
    apply {
        update_checksum_with_payload(hdr.tcp.flags, hdr.tcp.checksum);
    }
}

package top(ComputeChecksum<headers> _c);
top(computeChecksum()) main;
************************\n******** petr4 type checking result: ********\n************************\n
control ComputeChecksum<H> (inout H hdr);
extern void update_checksum_with_payload<T, O>(in T data, out O ck);
struct flags {
  bit<1> cwr;
}
header tcp {
  flags flags;
  bit<16> checksum;
}
struct headers {
  tcp tcp;
}
control computeChecksum(inout headers hdr) {
  apply {
    update_checksum_with_payload(hdr.tcp.flags, hdr.tcp.checksum);
  }
}
package top (ComputeChecksum<headers> _c);
top(computeChecksum()) main;

************************\n******** p4c type checking result: ********\n************************\n
