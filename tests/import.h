#pragma once
#include <stdbool.h>
#include <stdint.h>
#define TESTS_IMPORT_IMPORTED_LIB_ARRAY_FROM_IMPORTED_LIB_0 ("a")
#define TESTS_IMPORT_IMPORTED_LIB_ARRAY_FROM_IMPORTED_LIB_1 ("b")
#define TESTS_IMPORT_IMPORTED_LIB_PARAMETER_FROM_IMPORTED_LIB (21)
#define TESTS_IMPORT_IMPORTED_PARAMETER (42)
#define TESTS_IMPORT_ARRAY_0 (1)
#define TESTS_IMPORT_ARRAY_1 (4)
#define TESTS_IMPORT_ARRAY_2 (9)
#define TESTS_IMPORT_ARRAY_3 (16)
#define TESTS_IMPORT_ARRAY_4 (25)
#define TESTS_IMPORT_ARRAY_5 (36)
#define TESTS_IMPORT_ARRAY_6 (49)
#define TESTS_IMPORT_ARRAY_7 (64)
#define TESTS_IMPORT_ARRAY_8 (81)
#define TESTS_IMPORT_ARRAY_9 (100)
struct t_tests_import
{
    struct t_tests_import_imported_lib
    {
#define TESTS_IMPORT_IMPORTED_LIB_ARRAY_FROM_IMPORTED_LIB_SIZE1 2
#define TESTS_IMPORT_IMPORTED_LIB_ARRAY_FROM_IMPORTED_LIB_LEN 2
        char array_from_imported_lib[TESTS_IMPORT_IMPORTED_LIB_ARRAY_FROM_IMPORTED_LIB_SIZE1]
                                    [TESTS_IMPORT_IMPORTED_LIB_ARRAY_FROM_IMPORTED_LIB_LEN];
        uint8_t parameter_from_imported_lib;
    } imported_lib;
    uint8_t imported_parameter;
#define TESTS_IMPORT_ARRAY_SIZE1 10
    uint8_t array[TESTS_IMPORT_ARRAY_SIZE1];
};
extern const struct t_tests_import TESTS_IMPORT;
