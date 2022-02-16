/petr4/ci-test/type-checking/testdata/p4_16_samples/side_effects.p4
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

extern bit f(inout bit x, in bit y);
extern bit g(inout bit x);

header H { bit z; }

control c<T>(inout T t);
package top<T>(c<T> _c);

control my(inout H[2] s) {
    apply {
        bit a = 0;

        a = f(a, g(a));
        a = f(s[a].z, g(a));
        a = f(s[g(a)].z, a);
        a = g(a);
        a[0:0] = g(a[0:0]);
        s[a].z = g(a);
    }
}

top(my()) main;
************************\n******** petr4 type checking result: ********\n************************\n
