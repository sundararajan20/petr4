/petr4/ci-test/type-checking/testdata/p4_16_samples/initializer.p4
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

extern bit<32> random(bit<5> logRange);

control ingress(out bit<32> field_d_32) {
    action action_1() {
        {
            bit<32> tmp = random((bit<5>)24);
            field_d_32[31:8] = tmp[31:8];
        }
    }
    apply {
    }
}
************************\n******** petr4 type checking result: ********\n************************\n
extern bit<32> random(bit<5> logRange);
control ingress(out bit<32> field_d_32) {
  action action_1()
    {
    {
      bit<32> tmp = random((bit<5>) 24);
      field_d_32[31:8] = tmp[31:8];
    }
  }
  apply { 
  }
}

