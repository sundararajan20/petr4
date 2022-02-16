/petr4/ci-test/type-checking/testdata/p4_16_samples/parser-inline/parser-inline-test4.p4
\n
// Test of subparser inlining with following characteristics:
// - one subparser instance
// - two invocations of the same instance with the same arguments
// - no statement after both invocations
// - different transition select after both invocations

#include <v1model.p4>

struct metadata { }

header data_t {
    bit<8> f;
}

header data_t16 {
    bit<16> f;
}

struct headers {
    data_t   h1;
    data_t16 h2;
    data_t   h3;
    data_t   h4;
}

struct headers2 {
    data_t h1;
}

parser Subparser(      packet_in packet,
                 out   headers   hdr,
                 inout headers2  inout_hdr) {
    headers2 shdr;

    state start {
        packet.extract(hdr.h1);
        transition select(hdr.h1.f) {
            1: sp1;
            2: sp2;
            default: accept;
        }
    }

    state sp1 {
        packet.extract(hdr.h3);
        packet.extract(shdr.h1);
        transition sp3;
    }

    state sp2 {
        packet.extract(hdr.h2);
        transition accept;
    }

    state sp3 {
        inout_hdr.h1 = shdr.h1;
        transition accept;
    }
}

parser ParserImpl(      packet_in           packet,
                  out   headers             hdr,
                  inout metadata            meta,
                  inout standard_metadata_t standard_metadata) {
    Subparser() p;
    headers2 phdr;

    state start {
        packet.extract(phdr.h1);
        transition select(standard_metadata.ingress_port) {
            0: p0;
            1: p1;
            default: accept;
        }
    }

    state p0 {
        p.apply(packet, hdr, phdr);
        transition select (phdr.h1.f) {
            1: p2;
            default: accept;
        }
    }
    state p1 {
        p.apply(packet, hdr, phdr);
        transition select (phdr.h1.f) {
            1: reject;
            default: accept;
        }
    }

    state p2 {
        hdr.h4 = phdr.h1;
        transition accept;
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
        if (hdr.h2.isValid()) {
            standard_metadata.egress_spec = 2;
        } else if (hdr.h3.isValid()) {
            standard_metadata.egress_spec = 3;
        } else {
            standard_metadata.egress_spec = 10;
        }
    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr);
    }
}

control verifyChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

control computeChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

V1Switch(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;************************\n******** petr4 type checking result: ********\n************************\n
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
match_kind {
  range, optional, selector
}
const bit<32> __v1model_version = 20180101;
@metadata
@name("standard_metadata")
struct standard_metadata_t {
  bit<9> ingress_port;
  bit<9> egress_spec;
  bit<9> egress_port;
  bit<32> instance_type;
  bit<32> packet_length;
  @alias("queueing_metadata.enq_timestamp")
  bit<32> enq_timestamp;
  @alias("queueing_metadata.enq_qdepth")
  bit<19> enq_qdepth;
  @alias("queueing_metadata.deq_timedelta")
  bit<32> deq_timedelta;
  @alias("queueing_metadata.deq_qdepth")
  bit<19>
  deq_qdepth;
  @alias("intrinsic_metadata.ingress_global_timestamp")
  bit<48>
  ingress_global_timestamp;
  @alias("intrinsic_metadata.egress_global_timestamp")
  bit<48>
  egress_global_timestamp;
  @alias("intrinsic_metadata.mcast_grp")
  bit<16> mcast_grp;
  @alias("intrinsic_metadata.egress_rid")
  bit<16> egress_rid;
  bit<1> checksum_error;
  error parser_error;
  @alias("intrinsic_metadata.priority")
  bit<3> priority;
}
enum CounterType {
  packets, 
  bytes, 
  packets_and_bytes
}
enum MeterType {
  packets, 
  bytes
}
extern counter {
  counter(bit<32> size, CounterType type);
  void count(in bit<32> index);
}

extern direct_counter {
  direct_counter(CounterType type);
  void count();
}

extern meter {
  meter(bit<32> size, MeterType type);
  void execute_meter<T3>(in bit<32> index, out T3 result);
}

extern direct_meter<T4> {
  direct_meter(MeterType type);
  void read(out T4 result);
}

extern register<T5> {
  register(bit<32> size);
  @noSideEffects
  void read(out T5 result, in bit<32> index);
  void write(in bit<32> index, in T5 value);
}

extern action_profile {
  action_profile(bit<32> size);
}

extern void random<T6>(out T6 result, in T6 lo, in T6 hi);
extern void digest<T7>(in bit<32> receiver, in T7 data);
enum HashAlgorithm {
  crc32, 
  crc32_custom, 
  crc16, 
  crc16_custom, 
  random, 
  identity, 
  csum16, 
  xor16
}
@deprecated("Please use mark_to_drop(standard_metadata) instead.")
extern void mark_to_drop();
@pure
extern void mark_to_drop(inout standard_metadata_t standard_metadata);
@pure
extern void hash<O, T8, D, M>(out O result, in HashAlgorithm algo,
                              in T8 base, in D data, in M max);
extern action_selector {
  action_selector(HashAlgorithm algorithm, bit<32> size, bit<32> outputWidth);
}

enum CloneType {
  I2E, 
  E2E
}
@deprecated("Please use verify_checksum/update_checksum instead.")
extern Checksum16 {
  Checksum16();
  bit<16> get<D9>(in D9 data);
}

extern void verify_checksum<T10, O11>(in bool condition, in T10 data,
                                      in O11 checksum, HashAlgorithm algo);
@pure
extern void update_checksum<T12, O13>(in bool condition, in T12 data,
                                      inout O13 checksum,
                                      HashAlgorithm algo);
extern void verify_checksum_with_payload<T14, O15>(in bool condition,
                                                   in T14 data,
                                                   in O15 checksum,
                                                   HashAlgorithm algo);
@noSideEffects
extern void update_checksum_with_payload<T16, O17>(in bool condition,
                                                   in T16 data,
                                                   inout O17 checksum,
                                                   HashAlgorithm algo);
extern void clone(in CloneType type, in bit<32> session);
@deprecated("Please use 'resubmit_preserving_field_list' instead")
extern void resubmit<T18>(in T18 data);
extern void resubmit_preserving_field_list(bit<8> index);
@deprecated("Please use 'recirculate_preserving_field_list' instead")
extern void recirculate<T19>(in T19 data);
extern void recirculate_preserving_field_list(bit<8> index);
@deprecated("Please use 'clone_preserving_field_list' instead")
extern void clone3<T20>(in CloneType type, in bit<32> session, in T20 data);
extern void clone_preserving_field_list(in CloneType type,
                                        in bit<32> session, bit<8> index);
extern void truncate(in bit<32> length);
extern void assert(in bool check);
extern void assume(in bool check);
extern void log_msg(string msg);
extern void log_msg<T21>(string msg, in T21 data);
parser Parser<H, M22>
  (packet_in b,
   out H parsedHdr,
   inout M22 meta,
   inout standard_metadata_t standard_metadata);
control VerifyChecksum<H23, M24> (inout H23 hdr, inout M24 meta);
@pipeline
control Ingress<H25, M26>
  (inout H25 hdr, inout M26 meta, inout standard_metadata_t standard_metadata);
@pipeline
control Egress<H27, M28>
  (inout H27 hdr, inout M28 meta, inout standard_metadata_t standard_metadata);
control ComputeChecksum<H29, M30> (inout H29 hdr, inout M30 meta);
@deparser
control Deparser<H31> (packet_out b, in H31 hdr);
package V1Switch<H32, M33>
  (Parser<H32, M33> p,
   VerifyChecksum<H32, M33> vr,
   Ingress<H32, M33> ig,
   Egress<H32, M33> eg,
   ComputeChecksum<H32, M33> ck,
   Deparser<H32> dep);
struct metadata {
  
}
header data_t {
  bit<8> f;
}
header data_t16 {
  bit<16> f;
}
struct headers {
  data_t h1;
  data_t16 h2;
  data_t h3;
  data_t h4;
}
struct headers2 {
  data_t h1;
}
parser Subparser(packet_in packet, out headers hdr, inout headers2 inout_hdr) {
  headers2 shdr;
  state start
    {
    packet.extract(hdr.h1);
    transition select(hdr.h1.f) {
      1: sp1;
      2: sp2;
      default: accept;
    }
  }
  state sp1 {
    packet.extract(hdr.h3);
    packet.extract(shdr.h1);
    transition sp3;
  }
  state sp2 {
    packet.extract(hdr.h2);
    transition accept;
  }
  state sp3 {
    inout_hdr.h1 = shdr.h1;
    transition accept;
  }
}
parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
  Subparser() p;
  headers2 phdr;
  state start
    {
    packet.extract(phdr.h1);
    transition select(standard_metadata.ingress_port) {
      0: p0;
      1: p1;
      default: accept;
    }
  }
  state p0
    {
    p.apply(packet, hdr, phdr);
    transition select(phdr.h1.f) {
      1: p2;
      default: accept;
    }
  }
  state p1
    {
    p.apply(packet, hdr, phdr);
    transition select(phdr.h1.f) {
      1: reject;
      default: accept;
    }
  }
  state p2 {
    hdr.h4 = phdr.h1;
    transition accept;
  }
}
control ingress(inout headers hdr, inout metadata meta,
                inout standard_metadata_t standard_metadata) {
  apply
    {
    if (hdr.h2.isValid()) {
      standard_metadata.egress_spec = 2;
    }
       else if (hdr.h3.isValid()) {
              standard_metadata.egress_spec = 3;
       }else {
       standard_metadata.egress_spec = 10;
       }
  }
}
control egress(inout headers hdr, inout metadata meta,
               inout standard_metadata_t standard_metadata) {
  apply { 
  }
}
control DeparserImpl(packet_out packet, in headers hdr) {
  apply {
    packet.emit(hdr);
  }
}
control verifyChecksum(inout headers hdr, inout metadata meta) {
  apply { 
  }
}
control computeChecksum(inout headers hdr, inout metadata meta) {
  apply { 
  }
}
V1Switch(ParserImpl(), verifyChecksum(), ingress(), egress(),
           computeChecksum(), DeparserImpl())
  main;

