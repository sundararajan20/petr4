/petr4/ci-test/type-checking/testdata/p4_16_samples/issue2147-1.p4
\n
control ingress(inout bit<8> h) {
    action a(inout bit<8> b) {
    }
    apply {
        bit<8> tmp = h;
        a(tmp);
        h = tmp;
    }
}

control c<H>(inout H h);
package top<H>(c<H> c);
top(ingress()) main;
************************\n******** petr4 type checking result: ********\n************************\n
control ingress(inout bit<8> h) {
  action a(inout bit<8> b) { 
  }
  apply {
    bit<8> tmp = h;
    a(tmp);
    h = tmp;
  }
}
control c<H> (inout H h);
package top<H0> (c<H0> c);
top(ingress()) main;

