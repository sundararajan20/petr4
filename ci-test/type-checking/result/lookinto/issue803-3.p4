/petr4/ci-test/type-checking/testdata/p4_16_samples/issue803-3.p4
\n
#include <core.p4>

parser Parser<IH>(out IH parsedHeaders);
package Ingress<IH>(Parser<IH> p);
package Switch<IH>(Ingress<IH> ingress);

struct H {}

parser ing_parse(out H hdr) {
    state start {
        transition accept;
    }
}

Ingress<H>(ing_parse()) ig1;

Switch(ig1) main;
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
parser Parser<IH> (out IH parsedHeaders);
package Ingress<IH3> (Parser<IH3> p);
package Switch<IH4> (Ingress<IH4> ingress);
struct H {
  
}
parser ing_parse(out H hdr) {
  state start {
    transition accept;
  }
}
Ingress<H>(ing_parse()) ig1;
Switch(ig1) main;

