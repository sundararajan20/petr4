/petr4/ci-test/type-checking/testdata/p4_16_samples/octal.p4
\n
const bit<16> n1 = 16w0377;    // 377
const bit<16> n2 = 16w0o0377;  // 255
const bool t1 = (n1 == 377);
const bool t2 = (n1 == 255);
const bool t3 = (n2 == 377);
const bool t4 = (n2 == 255);
************************\n******** petr4 type checking result: ********\n************************\n
