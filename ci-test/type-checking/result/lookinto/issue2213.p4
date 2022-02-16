/petr4/ci-test/type-checking/testdata/p4_16_samples/issue2213.p4
\n
struct mystruct1_t {
    bit<16> f1;
}

struct mystruct2_t {
    mystruct1_t s1;
}

struct metadata_t {
    mystruct1_t s1;
    mystruct2_t s2;
}

control ingressImpl(inout metadata_t meta)
{
    apply {
        meta.s2 = {s1={f1=2}};
    }
}

control c(inout metadata_t meta);
package top(c _c);

top(ingressImpl()) main;
************************\n******** petr4 type checking result: ********\n************************\n
struct mystruct1_t {
  bit<16> f1;
}
struct mystruct2_t {
  mystruct1_t s1;
}
struct metadata_t {
  mystruct1_t s1;
  mystruct2_t s2;
}
control ingressImpl(inout metadata_t meta) {
  apply {
    meta.s2 = {s1 = {f1 = 2}};
  }
}
control c (inout metadata_t meta);
package top (c _c);
top(ingressImpl()) main;

