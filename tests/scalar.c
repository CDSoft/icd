#include "scalar.h"
const struct t_tests_scalar TESTS_SCALAR = {
    .a = 9223372036854775807LLU,
    .b = -9223372036854775807LL - 1LL,
    .b1 = -9223372036854775807LL,
    .b2 = -9223372036854775806LL,
    .b3 = -9223372036854775805LL,
    .b4 = -9223372036854775804LL,
    .boolean = {.f = false, .t = true},
    .floats = {.f1 = 0.0, .f2 = 1.0, .f3 = 3.1, .f4 = 3.1415926535898},
    .neg = {.a = -128, .b = -32768, .c = -2147483648, .d = -9223372036854775807LL - 1LL},
    .pos =
        {.a = 0, .b = 128, .c = 256, .d = 32768, .e = 65536, .f = 2147483648, .g = 4294967296LLU, .h = 8589934592LLU},
    .strings = {.s1 = "", .s2 = "hello", .s3 = "hello world!"},
};
