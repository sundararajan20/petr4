/petr4/ci-test/type-checking/testdata/p4_16_samples/version.p4
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

struct Version
{
    bit<8> major;
    bit<8> minor;
}
    
const .Version version = { 8w0, 8w1 };
************************\n******** petr4 type checking result: ********\n************************\n
struct Version {
  bit<8> major;
  bit<8> minor;
}
const .Version version = {8w0, 8w1};

