struct t_tests_import_imported_lib {
    string []array_from_imported_lib;
    int parameter_from_imported_lib;
}
struct t_tests_import {
    t_tests_import_imported_lib imported_lib;
    int imported_parameter;
    int []array;
}
t_tests_import tests_import;
tests_import.imported_lib.array_from_imported_lib[1] = "a";
tests_import.imported_lib.array_from_imported_lib[2] = "b";
tests_import.imported_lib.parameter_from_imported_lib = 21;
tests_import.imported_parameter = 42;
tests_import.array[1] = 1;
tests_import.array[2] = 4;
tests_import.array[3] = 9;
tests_import.array[4] = 16;
tests_import.array[5] = 25;
tests_import.array[6] = 36;
tests_import.array[7] = 49;
tests_import.array[8] = 64;
tests_import.array[9] = 81;
tests_import.array[10] = 100;

