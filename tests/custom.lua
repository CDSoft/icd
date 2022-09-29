local prelude = {
    c = [[
enum t_state { INIT, RUNNING, DEAD };
int fib(int x);
]],
    hs = [[
data State = INIT | RUNNING | DEAD
]],
}

local state = {
    c={t="enum t_state %s"},
    sh={v="%s"},
    hs={t="%s :: State"},
    asy={t="string %s", v=[["%s"]]},
    yaml={v=[["%s"]]},
}

local ptr = {
    c={t="void *%s", v="(void*)0x%08X"},
    sh={v="0x%08X"},
    hs={t="%s :: Int", v="0x%08X"},
    asy={t="int %s", v="%d"},
    yaml={v="%d"},
}

local func = {
    c={t="int (*%s)(int x)"},
    sh={v="%s"},
    hs={t="%s :: String", v=[["%s"]]},
    asy={t="string %s", v=[["%s"]]},
    yaml={v=[["%s"]]},
}

-- custom types can be defined in a library
local say_hello = require "tests/lib/custom_type"

return {
    __prelude = prelude,
    initial_state = {__custom=state, "INIT"},
    running = {__custom=state, "RUNNING"},
    my_ptr = {__custom=ptr, 0x1234},
    f = {__custom=func, "fib"},
    hellostr = {__custom=say_hello, "World!"},
    compound_custom = {__ctype = "struct t_compount_custom_type",
        __prelude = { c = [[
            struct t_compount_custom_type {
                int n;
                struct {
                    double x;
                    double y;
                } points[10];
            };
        ]]},
        n = 3,
        points = { {x=1, y=2}, {x=3, y=4}, {x=5, y=6} },
    },
}
