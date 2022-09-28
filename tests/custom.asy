struct t_tests_custom_compound_custom_points {
    int x;
    int y;
}
struct t_tests_custom_compound_custom {
    int n;
    t_tests_custom_compound_custom_points []points;
}
struct t_tests_custom {
    t_tests_custom_compound_custom compound_custom;
    string f;
    string hellostr;
    string initial_state;
    int my_ptr;
    string running;
}
t_tests_custom tests_custom;
tests_custom.compound_custom.n = 3;
tests_custom.compound_custom.points[1] = new t_tests_custom_compound_custom_points ;
tests_custom.compound_custom.points[1].x = 1;
tests_custom.compound_custom.points[1].y = 2;
tests_custom.compound_custom.points[2] = new t_tests_custom_compound_custom_points ;
tests_custom.compound_custom.points[2].x = 3;
tests_custom.compound_custom.points[2].y = 4;
tests_custom.compound_custom.points[3] = new t_tests_custom_compound_custom_points ;
tests_custom.compound_custom.points[3].x = 5;
tests_custom.compound_custom.points[3].y = 6;
tests_custom.f = "fib";
tests_custom.hellostr = "Hello World!";
tests_custom.initial_state = "INIT";
tests_custom.my_ptr = 4660;
tests_custom.running = "RUNNING";

