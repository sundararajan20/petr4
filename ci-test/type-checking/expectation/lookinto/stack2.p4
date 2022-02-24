/petr4/ci-test/type-checking/testdata/p4_16_samples/stack2.p4
\n
#include <core.p4>
header h { }
control c(out bit<32> x) {
    apply {
        h[4] stack;
        bit<32> sz = stack.size;
        x = sz;
    }
}
control Simpler(out bit<32> x);
package top(Simpler ctr);
top(c()) main;
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
header h {
  
}
control c(out bit<32> x) {
  apply {
    h[4] stack;
    bit<32> sz = stack.size;
    x = sz;
  }
}
control Simpler (out bit<32> x);
package top (Simpler ctr);
top(c()) main;

************************\n******** p4c type checking result: ********\n************************\n
