/petr4/ci-test/type-checking/testdata/p4_16_samples/direct-call1.p4
\n
parser p() {
    state start {
        transition accept;
    }
}

parser q() {
    state start {
        p.apply();
        transition accept;
    }
}
************************\n******** petr4 type checking result: ********\n************************\n
