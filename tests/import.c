#include "import.h"
const struct t_tests_import TESTS_IMPORT = {
    .imported_lib =
        {
            .array_from_imported_lib = {[0] = "a", [1] = "b"},
            .parameter_from_imported_lib = 21,
        },
    .imported_parameter = 42,
    .array = {[0] = 1, [1] = 4, [2] = 9, [3] = 16, [4] = 25, [5] = 36, [6] = 49, [7] = 64, [8] = 81, [9] = 100},
};
