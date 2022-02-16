/petr4/ci-test/type-checking/testdata/p4_16_samples/issue1638.p4
\n
#include <core.p4>

struct intrinsic_metadata_t {
   bit<8> f0;
   bit<8> f1;
}

struct empty_t {}

control C<H, M>(
    inout H hdr,
    inout M meta,
    in intrinsic_metadata_t intr_md);

package P<H, M>(C<H, M> c);

struct hdr_t { }
struct meta_t { bit<8> f0; bit<8> f1; bit<8> f2; }

control MyC2(in meta_t meta = {0, 0, 0}) {
  table a {
    key = {
      meta.f0 : exact;
    }
    actions = { NoAction; }
  }
  apply {
    a.apply();
  }
}

control MyC(inout hdr_t hdr, inout meta_t meta, in intrinsic_metadata_t intr_md) {
   MyC2() c2;
   apply {
     c2.apply();
   }
}

P(MyC()) main;
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
struct intrinsic_metadata_t {
  bit<8> f0;
  bit<8> f1;
}
struct empty_t {
  
}
control C<H, M> (inout H hdr, inout M meta, in intrinsic_metadata_t intr_md);
package P<H3, M4> (C<H3, M4> c);
struct hdr_t {
  
}
struct meta_t {
  bit<8> f0;
  bit<8> f1;
  bit<8> f2;
}
control MyC2(in meta_t meta= {0, 0, 0}) {
  table a {
    key = {
      meta.f0: exact;
    }
    actions = {
      NoAction;
    }
  }
  apply {
    a.apply();
  }
}
control MyC(inout hdr_t hdr, inout meta_t meta,
            in intrinsic_metadata_t intr_md) {
  MyC2() c2;
  apply {
    c2.apply();
  }
}
P(MyC()) main;

