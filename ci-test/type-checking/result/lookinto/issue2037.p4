/petr4/ci-test/type-checking/testdata/p4_16_samples/issue2037.p4
\n
action a() {}
control c() {
    table t {
        actions = { .a; }
        default_action = a;
    }
    apply {}
}
************************\n******** petr4 type checking result: ********\n************************\n
action a() { 
}
control c() {
  table t {
    actions = {
      .a;
    }
    default_action = a;
  }
  apply { 
  }
}

