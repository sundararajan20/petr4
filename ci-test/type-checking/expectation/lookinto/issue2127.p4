/petr4/ci-test/type-checking/testdata/p4_16_samples/issue2127.p4
\n
#include <core.p4>

header H {
    bit<32> b;
}

parser p(packet_in packet, out H h) {
    state start {
        packet.extract(h);
        ;
        transition accept;
    }
}

parser proto<T>(packet_in p, out T t);
package top<T>(proto<T> p);
top(p()) main;
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
header H {
  bit<32> b;
}
parser p(packet_in packet, out H h) {
  state start {
    packet.extract(h);
    ;
    transition accept;
  }
}
parser proto<T3> (packet_in p, out T3 t);
package top<T4> (proto<T4> p);
top(p()) main;

************************\n******** p4c type checking result: ********\n************************\n
