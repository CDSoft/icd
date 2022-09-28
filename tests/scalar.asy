struct t_tests_scalar_boolean {
    bool f;
    bool t;
}
struct t_tests_scalar_floats {
    real f1;
    real f2;
    real f3;
    real f4;
}
struct t_tests_scalar_neg {
    int a;
    int b;
    int c;
    int d;
}
struct t_tests_scalar_pos {
    int a;
    int b;
    int c;
    int d;
    int e;
    int f;
    int g;
    int h;
}
struct t_tests_scalar_strings {
    string s1;
    string s2;
    string s3;
}
struct t_tests_scalar {
    int a;
    int b;
    int b1;
    int b2;
    int b3;
    int b4;
    t_tests_scalar_boolean boolean;
    t_tests_scalar_floats floats;
    t_tests_scalar_neg neg;
    t_tests_scalar_pos pos;
    t_tests_scalar_strings strings;
}
t_tests_scalar tests_scalar;
tests_scalar.a = 9223372036854775807;
tests_scalar.b = -9223372036854775804-4;
tests_scalar.b1 = -9223372036854775804-3;
tests_scalar.b2 = -9223372036854775804-2;
tests_scalar.b3 = -9223372036854775804-1;
tests_scalar.b4 = -9223372036854775804;
tests_scalar.boolean.f = false;
tests_scalar.boolean.t = true;
tests_scalar.floats.f1 = 0.0;
tests_scalar.floats.f2 = 1.0;
tests_scalar.floats.f3 = 3.1;
tests_scalar.floats.f4 = 3.1415926535898;
tests_scalar.neg.a = -128;
tests_scalar.neg.b = -32768;
tests_scalar.neg.c = -2147483648;
tests_scalar.neg.d = -9223372036854775804-4;
tests_scalar.pos.a = 0;
tests_scalar.pos.b = 128;
tests_scalar.pos.c = 256;
tests_scalar.pos.d = 32768;
tests_scalar.pos.e = 65536;
tests_scalar.pos.f = 2147483648;
tests_scalar.pos.g = 4294967296;
tests_scalar.pos.h = 8589934592;
tests_scalar.strings.s1 = "";
tests_scalar.strings.s2 = "hello";
tests_scalar.strings.s3 = "hello world!";

