#pragma once
#include <stdbool.h>
#include <stdint.h>
#define TESTS_SCALAR_A (9223372036854775807LLU)
#define TESTS_SCALAR_B (-9223372036854775807LL - 1LL)
#define TESTS_SCALAR_B1 (-9223372036854775807LL)
#define TESTS_SCALAR_B2 (-9223372036854775806LL)
#define TESTS_SCALAR_B3 (-9223372036854775805LL)
#define TESTS_SCALAR_B4 (-9223372036854775804LL)
#define TESTS_SCALAR_BOOLEAN_F (false)
#define TESTS_SCALAR_BOOLEAN_T (true)
#define TESTS_SCALAR_FLOATS_F1 (0.0)
#define TESTS_SCALAR_FLOATS_F2 (1.0)
#define TESTS_SCALAR_FLOATS_F3 (3.1)
#define TESTS_SCALAR_FLOATS_F4 (3.1415926535898)
#define TESTS_SCALAR_NEG_A (-128)
#define TESTS_SCALAR_NEG_B (-32768)
#define TESTS_SCALAR_NEG_C (-2147483648)
#define TESTS_SCALAR_NEG_D (-9223372036854775807LL - 1LL)
#define TESTS_SCALAR_POS_A (0)
#define TESTS_SCALAR_POS_B (128)
#define TESTS_SCALAR_POS_C (256)
#define TESTS_SCALAR_POS_D (32768)
#define TESTS_SCALAR_POS_E (65536)
#define TESTS_SCALAR_POS_F (2147483648)
#define TESTS_SCALAR_POS_G (4294967296LLU)
#define TESTS_SCALAR_POS_H (8589934592LLU)
#define TESTS_SCALAR_STRINGS_S1 ("")
#define TESTS_SCALAR_STRINGS_S2 ("hello")
#define TESTS_SCALAR_STRINGS_S3 ("hello world!")
struct t_tests_scalar
{
    uint64_t a;
    int64_t b;
    int64_t b1;
    int64_t b2;
    int64_t b3;
    int64_t b4;
    struct t_tests_scalar_boolean
    {
        bool f;
        bool t;
    } boolean;
    struct t_tests_scalar_floats
    {
        double f1;
        double f2;
        double f3;
        double f4;
    } floats;
    struct t_tests_scalar_neg
    {
        int8_t a;
        int16_t b;
        int32_t c;
        int64_t d;
    } neg;
    struct t_tests_scalar_pos
    {
        uint8_t a;
        uint8_t b;
        uint16_t c;
        uint16_t d;
        uint32_t e;
        uint32_t f;
        uint64_t g;
        uint64_t h;
    } pos;
    struct t_tests_scalar_strings
    {
#define TESTS_SCALAR_STRINGS_S1_LEN 1
        char s1[TESTS_SCALAR_STRINGS_S1_LEN];
#define TESTS_SCALAR_STRINGS_S2_LEN 6
        char s2[TESTS_SCALAR_STRINGS_S2_LEN];
#define TESTS_SCALAR_STRINGS_S3_LEN 13
        char s3[TESTS_SCALAR_STRINGS_S3_LEN];
    } strings;
};
extern const struct t_tests_scalar TESTS_SCALAR;
