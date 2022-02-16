/petr4/ci-test/type-checking/testdata/p4_16_samples/issue2957.p4
\n
#include <core.p4>

bit<3> max(in bit<3> val, in bit<3> bound) {
    return (val < bound ? val : bound);
}
header ethernet_t {
    bit<48> dst_addr;
    bit<48> src_addr;
    bit<16> eth_type;
}

header H {
    bit<8> a;
}

struct Headers {
    ethernet_t eth_hdr;
    H[2]       h;
}

extern bit<8> extern_call(inout H val);
parser p(packet_in pkt, out Headers hdr) {
    H tmp = { extern_call(hdr.h[max(3w1, 3w2)]) };
    state start {
        transition parse_hdrs;
    }
    state parse_hdrs {
        pkt.extract(hdr.eth_hdr);
        pkt.extract(hdr.h.next);
        transition accept;
    }
}

control ingress(inout Headers h) {
    apply {
    }
}

parser Parser(packet_in b, out Headers hdr);
control Ingress(inout Headers hdr);
package top(Parser p, Ingress ig);
top(p(), ingress()) main;

************************\n******** petr4 type checking result: ********\n************************\n
error {
  NoError, PacketTooShort, NoMatch, StackOutOfBounds, HeaderTooShort,
  ParserTimeout, ParserInvalidArgument
}
extern packet_in {
  void extract<T>(out T hdr);
  void extract<T0>(out T0 variableSizeHeader,
                   in bit<32> variableFieldSizeInBits);
  T1 lookahead<T1>();
  void advance(in bit<32> sizeInBits);
  bit<32> length();
}

extern packet_out {
  void emit<T2>(in T2 hdr);
}

extern void verify(in bool check, in error toSignal);
@noWarn("unused")
action NoAction() { 
}
match_kind {
  exact, ternary, lpm
}
bit<3> max (in bit<3> val, in bit<3> bound)
  {
  return (val<bound ? val : bound);
}
header ethernet_t {
  bit<48> dst_addr;
  bit<48> src_addr;
  bit<16> eth_type;
}
header H {
  bit<8> a;
}
struct Headers {
  ethernet_t eth_hdr;
  H[2] h;
}
extern bit<8> extern_call(inout H val);
parser p(packet_in pkt, out Headers hdr) {
  H tmp = {extern_call(hdr.h[max(3w1, 3w2)])};
  state start {
    transition parse_hdrs;
  }
  state parse_hdrs
    {
    pkt.extract(hdr.eth_hdr);
    pkt.extract(hdr.h.next);
    transition accept;
  }
}
control ingress(inout Headers h) {
  apply { 
  }
}
parser Parser (packet_in b, out Headers hdr);
control Ingress (inout Headers hdr);
package top (Parser p, Ingress ig);
top(p(), ingress()) main;

************************\n******** p4c type checking result: ********\n************************\n
