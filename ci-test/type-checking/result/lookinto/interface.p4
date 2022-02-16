/petr4/ci-test/type-checking/testdata/p4_16_samples/interface.p4
\n
/*
Copyright 2013-present Barefoot Networks, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#include <core.p4>

extern Crc16 <T> {
        Crc16();
        Crc16(int<32> x);
        void initialize<U>(in U input_data);
        T value();
        T make_index(
            in T size,
            in T base
        );
}

control p() {
    Crc16<bit<32>>() crc0;
    Crc16<int<32>>(32s0) crc1;
    Crc16<int<32>>()  crc2;

    apply {}
}

control empty();

package m(empty e);

m(p()) main;
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
extern Crc16<T3> {
  Crc16();
  Crc16(int<32> x);
  void initialize<U>(in U input_data);
  T3 value();
  T3 make_index(in T3 size, in T3 base);
}

control p() {
  Crc16<bit<32>>() crc0;
  Crc16<int<32>>(32s0) crc1;
  Crc16<int<32>>() crc2;
  apply { 
  }
}
control empty ();
package m (empty e);
m(p()) main;

