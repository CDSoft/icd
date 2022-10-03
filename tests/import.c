#include "import.h"
const struct t_tests_import TESTS_IMPORT = {
    .imported_lib =
        {
            .array_from_imported_lib = {[0] = "a", [1] = "b"},
            .parameter_from_imported_lib = 21,
        },
    .imported_parameter = 42,
};
