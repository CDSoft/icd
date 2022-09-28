#pragma once
#include <stdbool.h>
#include <stdint.h>
enum t_state { INIT, RUNNING, DEAD };
int fib(int x);
struct t_compount_custom_type {
    int n;
    struct {
        double x;
        double y;
    } points[10];
};
#define TESTS_CUSTOM_COMPOUND_CUSTOM_N (3)
#define TESTS_CUSTOM_COMPOUND_CUSTOM_POINTS_1_X (1)
#define TESTS_CUSTOM_COMPOUND_CUSTOM_POINTS_1_Y (2)
#define TESTS_CUSTOM_COMPOUND_CUSTOM_POINTS_2_X (3)
#define TESTS_CUSTOM_COMPOUND_CUSTOM_POINTS_2_Y (4)
#define TESTS_CUSTOM_COMPOUND_CUSTOM_POINTS_3_X (5)
#define TESTS_CUSTOM_COMPOUND_CUSTOM_POINTS_3_Y (6)
#define TESTS_CUSTOM_F (fib)
#define TESTS_CUSTOM_HELLOSTR ("Hello World!")
#define TESTS_CUSTOM_INITIAL_STATE (INIT)
#define TESTS_CUSTOM_MY_PTR ((void*)0x00001234)
#define TESTS_CUSTOM_RUNNING (RUNNING)
struct t_tests_custom
{
    struct t_compount_custom_type compound_custom;
    int (*f)(int x);
    char *hellostr;
    enum t_state initial_state;
    void *my_ptr;
    enum t_state running;
};
extern const struct t_tests_custom TESTS_CUSTOM;
