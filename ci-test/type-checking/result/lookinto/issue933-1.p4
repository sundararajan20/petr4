/petr4/ci-test/type-checking/testdata/p4_16_samples/issue933-1.p4
\n
#include <core.p4>

/* Program */
struct headers {
    bit<32> x;
}

extern void f(headers h);

control c() {
    apply {
        headers h;
        f({ 5 });
    }
}

control C();
package top(C _c);

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
struct headers {
  bit<32> x;
}
extern void f(headers h);
control c() {
  apply {
    headers h;
    f({5});
  }
}
control C ();
package top (C _c);
top(c()) main;

