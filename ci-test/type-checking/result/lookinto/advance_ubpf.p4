/petr4/ci-test/type-checking/testdata/p4_16_samples/advance_ubpf.p4
\n
#include <core.p4>
#define UBPF_MODEL_VERSION 20200515
#include <ubpf_model.p4>

header test_header {
    bit<8> bits_to_skip;
}

struct Headers_t {
    test_header skip;
}

struct metadata {
}

parser prs(packet_in p, out Headers_t headers, inout metadata meta, inout standard_metadata std_meta) {
    state start {
        p.extract(headers.skip);
        p.advance((bit<32>) headers.skip.bits_to_skip);
        transition accept;
    }
}

control pipe(inout Headers_t headers, inout metadata meta, inout standard_metadata std_meta) {
    apply { }
}

control dprs(packet_out packet, in Headers_t headers) {
    apply {
        packet.emit(headers.skip);
    }
}

ubpf(prs(), pipe(), dprs()) main;
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
const bit<32> __ubpf_model_version = 20200515;
enum ubpf_action {
  ABORT, 
  DROP, 
  PASS, 
  REDIRECT
}
struct standard_metadata {
  bit<32> input_port;
  bit<32> packet_length;
  ubpf_action output_action;
  bit<32> output_port;
  bool clone;
  bit<32> clone_port;
}
extern void mark_to_drop();
extern void mark_to_pass();
extern Register<T3, S> {
  Register(bit<32> size);
  T3 read(in S index);
  void write(in S index, in T3 value);
}

extern bit<48> ubpf_time_get_ns();
extern void truncate(in bit<32> len);
enum HashAlgorithm {
  lookup3
}
extern void hash<D>(out bit<32> result, in HashAlgorithm algo, in D data);
extern bit<16> csum_replace2(in bit<16> csum, in bit<16> old,
                             in bit<16> new);
extern bit<16> csum_replace4(in bit<16> csum, in bit<32> old,
                             in bit<32> new);
parser parse<H, M>
  (packet_in packet, out H headers, inout M meta, inout standard_metadata std);
control pipeline<H4, M5>
  (inout H4 headers, inout M5 meta, inout standard_metadata std);
@deparser
control deparser<H6> (packet_out b, in H6 headers);
package ubpf<H7, M8>
  (parse<H7, M8> prs, pipeline<H7, M8> p, deparser<H7> dprs);
header test_header {
  bit<8> bits_to_skip;
}
struct Headers_t {
  test_header skip;
}
struct metadata {
  
}
parser prs(packet_in p, out Headers_t headers, inout metadata meta,
           inout standard_metadata std_meta) {
  state start
    {
    p.extract(headers.skip);
    p.advance((bit<32>) headers.skip.bits_to_skip);
    transition accept;
  }
}
control pipe(inout Headers_t headers, inout metadata meta,
             inout standard_metadata std_meta) {
  apply { 
  }
}
control dprs(packet_out packet, in Headers_t headers) {
  apply {
    packet.emit(headers.skip);
  }
}
ubpf(prs(), pipe(), dprs()) main;

