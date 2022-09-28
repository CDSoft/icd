#include "custom.h"
const struct t_tests_custom TESTS_CUSTOM = {
    .compound_custom = {
        .n = 3,
        .points = {
            [0] = {.x = 1, .y = 2},
            [1] = {.x = 3, .y = 4},
            [2] = {.x = 5, .y = 6},
        },
    },
    .f = fib,
    .hellostr = "Hello World!",
    .initial_state = INIT,
    .my_ptr = (void*)0x00001234,
    .running = RUNNING,
};
