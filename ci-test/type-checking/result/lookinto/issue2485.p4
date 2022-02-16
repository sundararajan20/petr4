/petr4/ci-test/type-checking/testdata/p4_16_samples/issue2485.p4
\n
#include <core.p4>

header H {
    bit<16> a;
}


struct metadata {
}

struct Headers {
    H h;
}

parser p(packet_in packet, out Headers hdr) {
    state start {
        packet.extract(hdr.h);
        transition select(hdr.h.a) {
            0x0000 .. 0x0004: parse;
            default: accept;
        }
    }
    state parse {
        hdr.h.a = 1;
        transition accept;
    }

}



parser Parser(packet_in b, out Headers hdr);
package top(Parser p);
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
  bit<16> a;
}
struct metadata {
  
}
struct Headers {
  H h;
}
parser p(packet_in packet, out Headers hdr) {
  state start
    {
    packet.extract(hdr.h);
    transition select(hdr.h.a) {
      0 .. 4: parse;
      default: accept;
    }
  }
  state parse {
    hdr.h.a = 1;
    transition accept;
  }
}
parser Parser (packet_in b, out Headers hdr);
package top (Parser p);
top(p()) main;

