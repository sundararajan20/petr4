/petr4/ci-test/type-checking/testdata/p4_16_samples/valid_ebpf.p4
\n
#include <ebpf_model.p4>
#include <core.p4>

#include "ebpf_headers.p4"

struct Headers_t
{
    Ethernet_h ethernet;
    IPv4_h     ipv4;
}

parser prs(packet_in p, out Headers_t headers)
{
    state start
    {
        p.extract(headers.ethernet);
        transition select(headers.ethernet.etherType)
        {
            16w0x800 : ip;
            default : reject;
        }
    }

    state ip
    {
        p.extract(headers.ipv4);
        transition accept;
    }
}

control pipe(inout Headers_t headers, out bool pass)
{
    CounterArray(32w10, true) counters;

    action invalidate() {
        headers.ipv4.setInvalid();
        headers.ethernet.setInvalid();
    }
    table t {
        actions = {
            invalidate;
        }
        implementation = array_table(1);
    }

    apply {
        if (headers.ipv4.isValid())
        {
            counters.increment((bit<32>)headers.ipv4.dstAddr);
            pass = true;
        }
        else {
            t.apply();
            pass = false;
        }
    }
}

ebpfFilter(prs(), pipe()) main;
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
@ethernetaddress
typedef bit<48> EthernetAddress;
@ipv4address
typedef bit<32> IPv4Address;
header Ethernet_h {
  EthernetAddress dstAddr;
  EthernetAddress srcAddr;
  bit<16> etherType;
}
header IPv4_h {
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
}
struct Headers_t {
  Ethernet_h ethernet;
  IPv4_h ipv4;
}
parser prs(packet_in p, out Headers_t headers) {
  state start
    {
    p.extract(headers.ethernet);
    transition select(headers.ethernet.etherType) {
      16w2048: ip;
      default: reject;
    }
  }
  state ip {
    p.extract(headers.ipv4);
    transition accept;
  }
}
control pipe(inout Headers_t headers, out bool pass) {
  CounterArray(32w10, true) counters;
  action invalidate()
    {
    headers.ipv4.setInvalid();
    headers.ethernet.setInvalid();
  }
  table t {
    actions = {
      invalidate;
    }
    implementation = array_table(1);
  }
  apply
    {
    if (headers.ipv4.isValid())
      {
      counters.increment((bit<32>) headers.ipv4.dstAddr);
      pass = true;
    }else {
    t.apply();
    pass = false;
    }
  }
}
ebpfFilter(prs(), pipe()) main;

