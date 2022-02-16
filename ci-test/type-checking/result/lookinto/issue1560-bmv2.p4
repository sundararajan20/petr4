/petr4/ci-test/type-checking/testdata/p4_16_samples/issue1560-bmv2.p4
\n
#include <core.p4>
#include <v1model.p4>

typedef bit<48>  EthernetAddress;
typedef bit<32>  IPv4Address;

header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}

// IPv4 header _with_ options
header ipv4_t {
    bit<4>       version;
    bit<4>       ihl;
    bit<8>       diffserv;
    bit<16>      totalLen;
    bit<16>      identification;
    bit<3>       flags;
    bit<13>      fragOffset;
    bit<8>       ttl;
    bit<8>       protocol;
    bit<16>      hdrChecksum;
    IPv4Address  srcAddr;
    IPv4Address  dstAddr;
    varbit<320>  options;
}

header tcp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<32> seqNo;
    bit<32> ackNo;
    bit<4>  dataOffset;
    bit<3>  res;
    bit<3>  ecn;
    bit<6>  ctrl;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgentPtr;
}

header IPv4_up_to_ihl_only_h {
    bit<4>       version;
    bit<4>       ihl;
}

struct headers {
    ethernet_t    ethernet;
    ipv4_t        ipv4;
    tcp_t         tcp;
}

struct mystruct1_t {
    bit<4>  a;
    bit<4>  b;
}

struct metadata {
    mystruct1_t mystruct1;
    bit<16> hash1;
}

// Declare user-defined errors that may be signaled during parsing
error {
    IPv4HeaderTooShort,
    IPv4IncorrectVersion,
    IPv4ChecksumError
}

parser parserI(packet_in pkt,
               out headers hdr,
               inout metadata meta,
               inout standard_metadata_t stdmeta)
{
    state start {
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            0x0800: parse_ipv4;
            default: accept;
        }
    }
    state parse_ipv4 {
        // The 4-bit IHL field of the IPv4 base header is the number
        // of 32-bit words in the entire IPv4 header.  It is an error
        // for it to be less than 5.  There are only IPv4 options
        // present if the value is at least 6.  The length of the IPv4
        // options alone, without the 20-byte base header, is thus ((4
        // * ihl) - 20) bytes, or 8 times that many bits.
        pkt.extract(hdr.ipv4,
                    (bit<32>)
                    (8 *
                     (4 * (bit<9>) (pkt.lookahead<IPv4_up_to_ihl_only_h >().ihl)
                      - 20)));
        verify(hdr.ipv4.version == 4w4, error.IPv4IncorrectVersion);
        verify(hdr.ipv4.ihl >= 4w5, error.IPv4HeaderTooShort);
        transition select (hdr.ipv4.protocol) {
            6: parse_tcp;
            default: accept;
        }
    }
    state parse_tcp {
        pkt.extract(hdr.tcp);
        transition accept;
    }
}

control cIngress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t stdmeta)
{
    action foo1(IPv4Address dstAddr) {
        hdr.ipv4.dstAddr = dstAddr;
    }
    action foo2(IPv4Address srcAddr) {
        hdr.ipv4.srcAddr = srcAddr;
    }
    // Only defined here so that there is an action name that isn't an
    // allowed action for table t1, so I can test whether
    // simple_switch_CLI's act_prof_create_member command checks
    // whether the action name is legal according to the P4 program.
    action foo3(bit<8> ttl) {
        hdr.ipv4.ttl = ttl;
    }
    table t0 {
        key = {
            hdr.tcp.dstPort : exact;
        }
        actions = {
            foo1;
            foo2;
        }
        size = 8;
    }
    table t1 {
        key = {
            hdr.tcp.dstPort : exact;
        }
        actions = {
            foo1;
            foo2;
        }
        size = 8;
        //implementation = action_profile(4);
    }
    table t2 {
        actions = {
            foo1;
            foo2;
        }
        key = {
            hdr.tcp.srcPort : exact;
            meta.hash1      : selector;
        }
        size = 16;
        //@mode("fair") implementation = action_selector(HashAlgorithm.identity, 16, 4);
    }
    apply {
        t0.apply();
        t1.apply();

        //hash(meta.hash1, HashAlgorithm.crc16, (bit<16>) 0,
        //    { hdr.ipv4.srcAddr,
        //        hdr.ipv4.dstAddr,
        //        hdr.ipv4.protocol,
        //        hdr.tcp.srcPort,
        //        hdr.tcp.dstPort },
        //    (bit<32>) 65536);

        // The following assignment isn't really a good hash function
        // for calculating meta.hash1.  I wrote it this way simply to
        // make it easy to control and predict what its value will be
        // when sending in test packets.
        meta.hash1 = hdr.ipv4.dstAddr[15:0];
        t2.apply();
    }
}

control cEgress(inout headers hdr,
                inout metadata meta,
                inout standard_metadata_t stdmeta)
{
    apply { }
}

control vc(inout headers hdr,
           inout metadata meta)
{
    apply { }
}

control uc(inout headers hdr,
           inout metadata meta)
{
    apply { }
}

control DeparserI(packet_out packet,
                  in headers hdr)
{
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.tcp);
    }
}

V1Switch<headers, metadata>(parserI(),
                            vc(),
                            cIngress(),
                            cEgress(),
                            uc(),
                            DeparserI()) main;
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
typedef bit<48> EthernetAddress;
typedef bit<32> IPv4Address;
header ethernet_t {
  bit<48> dstAddr;
  bit<48> srcAddr;
  bit<16> etherType;
}
header ipv4_t {
  bit<4> version;
  bit<4> ihl;
  bit<8> diffserv;
  bit<16> totalLen;
  bit<16> identification;
  bit<3> flags;
  bit<13> fragOffset;
  bit<8> ttl;
  bit<8> protocol;
  bit<16> hdrChecksum;
  IPv4Address srcAddr;
  IPv4Address dstAddr;
  varbit <320> options;
}
header tcp_t {
  bit<16> srcPort;
  bit<16> dstPort;
  bit<32> seqNo;
  bit<32> ackNo;
  bit<4> dataOffset;
  bit<3> res;
  bit<3> ecn;
  bit<6> ctrl;
  bit<16> window;
  bit<16> checksum;
  bit<16> urgentPtr;
}
header IPv4_up_to_ihl_only_h {
  bit<4> version;
  bit<4> ihl;
}
struct headers {
  ethernet_t ethernet;
  ipv4_t ipv4;
  tcp_t tcp;
}
struct mystruct1_t {
  bit<4> a;
  bit<4> b;
}
struct metadata {
  mystruct1_t mystruct1;
  bit<16> hash1;
}
error {
  IPv4HeaderTooShort, IPv4IncorrectVersion, IPv4ChecksumError
}
parser parserI(packet_in pkt, out headers hdr, inout metadata meta,
               inout standard_metadata_t stdmeta) {
  state start
    {
    pkt.extract(hdr.ethernet);
    transition select(hdr.ethernet.etherType) {
      2048: parse_ipv4;
      default: accept;
    }
  }
  state parse_ipv4
    {
    pkt.extract(hdr.ipv4,
                  (bit<32>) 8*4*(bit<9>) pkt.lookahead<IPv4_up_to_ihl_only_h>().ihl-20);
    verify(hdr.ipv4.version==4w4, IPv4IncorrectVersion);
    verify(hdr.ipv4.ihl>=4w5, IPv4HeaderTooShort);
    transition select(hdr.ipv4.protocol) {
      6: parse_tcp;
      default: accept;
    }
  }
  state parse_tcp {
    pkt.extract(hdr.tcp);
    transition accept;
  }
}
control cIngress(inout headers hdr, inout metadata meta,
                 inout standard_metadata_t stdmeta) {
  action foo1(IPv4Address dstAddr) {
    hdr.ipv4.dstAddr = dstAddr;
  }
  action foo2(IPv4Address srcAddr) {
    hdr.ipv4.srcAddr = srcAddr;
  }
  action foo3(bit<8> ttl) {
    hdr.ipv4.ttl = ttl;
  }
  table t0 {
    key = {
      hdr.tcp.dstPort: exact;
    }
    actions = {
      foo1;foo2;
    }
    size = 8;
  }
  table t1 {
    key = {
      hdr.tcp.dstPort: exact;
    }
    actions = {
      foo1;foo2;
    }
    size = 8;
  }
  table t2
    {
    actions = {
      foo1;foo2;
    }
    key = {
      hdr.tcp.srcPort: exact;
      meta.hash1: selector;
    }
    size = 16;
  }
  apply
    {
    t0.apply();
    t1.apply();
    meta.hash1 = hdr.ipv4.dstAddr[15:0];
    t2.apply();
  }
}
control cEgress(inout headers hdr, inout metadata meta,
                inout standard_metadata_t stdmeta) {
  apply { 
  }
}
control vc(inout headers hdr, inout metadata meta) {
  apply { 
  }
}
control uc(inout headers hdr, inout metadata meta) {
  apply { 
  }
}
control DeparserI(packet_out packet, in headers hdr) {
  apply
    {
    packet.emit(hdr.ethernet);
    packet.emit(hdr.ipv4);
    packet.emit(hdr.tcp);
  }
}
V1Switch<headers, metadata>(parserI(), vc(), cIngress(), cEgress(), uc(),
                              DeparserI())
  main;

