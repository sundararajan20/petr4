/petr4/ci-test/type-checking/testdata/p4_16_samples/issue2797_ebpf.p4
\n
#include <ebpf_model.p4>
#include <core.p4>

header X {
    bit<1>  dc;
    bit<3>  cpd;
    bit<2>  snpadding;
    bit<16> sn;
    bit<2>  e;
}

struct Headers_t {
    X x;
}

parser prs(packet_in p, out Headers_t headers) {
    state start  {
        p.extract(headers.x);
        transition accept;
    }
}

control pipe(inout Headers_t headers, out bool pass) {
    apply {
        pass = true;
        if (!headers.x.isValid()) {
            pass = false;
            return;
        }
    }
}

ebpfFilter(prs(), pipe()) main;************************\n******** petr4 type checking result: ********\n************************\n
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
extern CounterArray {
  CounterArray(bit<32> max_index, bool sparse);
  void increment(in bit<32> index);
  void add(in bit<32> index, in bit<32> value);
}

extern array_table {
  array_table(bit<32> size);
}

extern hash_table {
  hash_table(bit<32> size);
}

parser parse<H> (packet_in packet, out H headers);
control filter<H3> (inout H3 headers, out bool accept);
package ebpfFilter<H4> (parse<H4> prs, filter<H4> filt);
header X {
  bit<1> dc;
  bit<3> cpd;
  bit<2> snpadding;
  bit<16> sn;
  bit<2> e;
}
struct Headers_t {
  X x;
}
parser prs(packet_in p, out Headers_t headers) {
  state start {
    p.extract(headers.x);
    transition accept;
  }
}
control pipe(inout Headers_t headers, out bool pass) {
  apply {
    pass = true;
    if (!headers.x.isValid()) {
      pass = false;
      return;
    }
  }
}
ebpfFilter(prs(), pipe()) main;

