/petr4/ci-test/type-checking/testdata/p4_16_samples/pred.p4
\n
/*
Copyright 2016 VMware, Inc.

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
#include <v1model.p4>

control empty();
package top(empty e);

control Ing() {
    bool b;
    bit<32> a;

    action cond() {
        b = true;
        if (b)
           a = 5;
        else
           a = 10;
    }

    apply {
        cond();
    }
}

top(Ing()) main;
************************\n******** petr4 type checking result: ********\n************************\n
