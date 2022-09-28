struct t_tests_import_imported_lib {
    int parameter_from_imported_lib;
}
struct t_tests_import {
    t_tests_import_imported_lib imported_lib;
    int imported_parameter;
}
t_tests_import tests_import;
tests_import.imported_lib.parameter_from_imported_lib = 21;
tests_import.imported_parameter = 42;

