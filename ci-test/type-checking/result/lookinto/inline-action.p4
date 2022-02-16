/petr4/ci-test/type-checking/testdata/p4_16_samples/inline-action.p4
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

control p(inout bit bt) {
    action a(inout bit y0)
    { y0 = y0 | 1w1; }

    action b() {
        a(bt);
        a(bt);
    }

    table t {
        actions = { b; }
        default_action = b;
    }

    apply {
        t.apply();
    }
}

control simple<T>(inout T arg);
package m<T>(simple<T> pipe);

m(p()) main;
************************\n******** petr4 type checking result: ********\n************************\n
control p(inout bit<1> bt) {
  action a(inout bit<1> y0) {
    y0 = y0 | 1w1;
  }
  action b() {
    a(bt);
    a(bt);
  }
  table t {
    actions = {
      b;
    }
    default_action = b;
  }
  apply {
    t.apply();
  }
}
control simple<T> (inout T arg);
package m<T0> (simple<T0> pipe);
m(p()) main;

