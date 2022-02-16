/petr4/ci-test/type-checking/testdata/p4_16_samples/issue1466.p4
\n
header hdr {
   bit<1> g;
}

control B(inout hdr _hdr, bit<1> _x) { // Note directionless parameter x
    apply {
        _hdr.g = _x;
    }
}

control A(inout hdr _hdr) {
    B() b_inst;

    apply {
        // Call the same instance twice
        b_inst.apply(_hdr, 1w1);
        b_inst.apply(_hdr, 1w1);
    }
}

control proto(inout hdr _hdr);
package top(proto p);

top(A()) main;
************************\n******** petr4 type checking result: ********\n************************\n
