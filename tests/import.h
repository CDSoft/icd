#pragma once
#include <stdbool.h>
#include <stdint.h>
#define TESTS_IMPORT_IMPORTED_LIB_ARRAY_FROM_IMPORTED_LIB_1 ("a")
#define TESTS_IMPORT_IMPORTED_LIB_ARRAY_FROM_IMPORTED_LIB_2 ("b")
#define TESTS_IMPORT_IMPORTED_LIB_PARAMETER_FROM_IMPORTED_LIB (21)
#define TESTS_IMPORT_IMPORTED_PARAMETER (42)
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
};
extern const struct t_tests_import TESTS_IMPORT;
