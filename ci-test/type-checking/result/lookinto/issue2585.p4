/petr4/ci-test/type-checking/testdata/p4_16_samples/issue2585.p4
\n
#include <core.p4>

header Header {
    bit<32> data;
    bit<32> data2;
}

parser p0(packet_in p, out Header h) {
    state start {
        p.extract(h);
        h.data = h.data2 - 8 - 8 - 2 - 16;
        transition accept;
    }
}

parser proto(packet_in p, out Header h);
package top(proto _p);

top(p0()) main;
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
header Header {
  bit<32> data;
  bit<32> data2;
}
parser p0(packet_in p, out Header h) {
  state start {
    p.extract(h);
    h.data = h.data2-8-8-2-16;
    transition accept;
  }
}
parser proto (packet_in p, out Header h);
package top (proto _p);
top(p0()) main;

