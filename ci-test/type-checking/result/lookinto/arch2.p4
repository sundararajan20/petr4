/petr4/ci-test/type-checking/testdata/p4_16_samples/arch2.p4
\n
#include <core.p4>
    
typedef bit<4> PortId;
    
struct InControl {
    PortId inputPort;
}
    
struct OutControl {
    PortId outputPort;
}    
        
parser Parser<IH>(packet_in b, out IH parsedHeaders);
    
control IPipe<T, IH, OH>(in IH inputHeaders,
                         in InControl inCtrl,
                         out OH outputHeaders,
                         out T toEgress,
                         out OutControl outCtrl);
    
control EPipe<T, IH, OH>(in IH inputHeaders,
                         in InControl inCtrl,
                         in T fromIngress,
                         out OH outputHeaders,
                         out OutControl outCtrl);
    
control Deparser<OH>(in OH outputHeaders, packet_out b);
    
package Ingress<T, IH, OH>(Parser<IH> p,
                           IPipe<T, IH, OH> map,
                           Deparser<OH> d);
    
package Egress<T, IH, OH>(Parser<IH> p,
                          EPipe<T, IH, OH> map,
                          Deparser<OH> d);
    
package Switch<T,H1,H2,H3,H4>(Ingress<T, H1, H2> ingress, Egress<T, H3, H4> egress);************************\n******** petr4 type checking result: ********\n************************\n
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
typedef bit<4> PortId;
struct InControl {
  PortId inputPort;
}
struct OutControl {
  PortId outputPort;
}
parser Parser<IH> (packet_in b, out IH parsedHeaders);
control IPipe<T3, IH4, OH>
  (in IH4 inputHeaders,
   in InControl inCtrl,
   out OH outputHeaders,
   out T3 toEgress,
   out OutControl outCtrl);
control EPipe<T5, IH6, OH7>
  (in IH6 inputHeaders,
   in InControl inCtrl,
   in T5 fromIngress,
   out OH7 outputHeaders,
   out OutControl outCtrl);
control Deparser<OH8> (in OH8 outputHeaders, packet_out b);
package Ingress<T9, IH10, OH11>
  (Parser<IH10> p, IPipe<T9, IH10, OH11> map, Deparser<OH11> d);
package Egress<T12, IH13, OH14>
  (Parser<IH13> p, EPipe<T12, IH13, OH14> map, Deparser<OH14> d);
package Switch<T15, H1, H2, H3, H4>
  (Ingress<T15, H1, H2> ingress, Egress<T15, H3, H4> egress);

************************\n******** p4c type checking result: ********\n************************\n
