#pragma once
#include <stdbool.h>
#include <stdint.h>
#define TESTS_IMPORT_IMPORTED_LIB_PARAMETER_FROM_IMPORTED_LIB (21)
#define TESTS_IMPORT_IMPORTED_PARAMETER (42)
struct t_tests_import
{
    struct t_tests_import_imported_lib
    {
        uint8_t parameter_from_imported_lib;
    } imported_lib;
    uint8_t imported_parameter;
};
extern const struct t_tests_import TESTS_IMPORT;
