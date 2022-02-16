/petr4/ci-test/type-checking/testdata/p4_16_samples/issue2288-1.p4
\n
header H {
    bit<8> a;
    bit<8> b;
}

struct Headers {
    H h;
}

bit<8> f(in bit<8> x, in bit<8> y, out bit<8> z) {
    z = x | y;
    return 8w4;
}

bit<8> g(out bit<8> w) {
    w = 8w3;
    return 8w1;
}

control ingress(inout Headers h) {
    apply {
        f(h.h.a, g(h.h.a), h.h.b);
    }
}

control i(inout Headers h);
package top(i _i);

top(ingress()) main;
************************\n******** petr4 type checking result: ********\n************************\n
header H {
  bit<8> a;
  bit<8> b;
}
struct Headers {
  H h;
}
bit<8> f (in bit<8> x, in bit<8> y, out bit<8> z) {
  z = x | y;
  return 8w4;
}
bit<8> g (out bit<8> w) {
  w = 8w3;
  return 8w1;
}
control ingress(inout Headers h) {
  apply {
    f(h.h.a, g(h.h.a), h.h.b);
  }
}
control i (inout Headers h);
package top (i _i);
top(ingress()) main;

************************\n******** p4c type checking result: ********\n************************\n
