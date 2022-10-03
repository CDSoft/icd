return {
    FLAT_STRUCTURE = {
        field1 = 42,
        field2 = "fourty two",
        field3 = true,
        field4 = math.pi,
    },

    FLAT_ARRAY = { 10, 20, 30, 40 },

    MEGA_STRUCT = {
        field_01 = 42,
        field_02 = { x=0, y=1 },
        field_03 = { a="hi", b = true},
        field_04 = { "one", "two", "three" },
        field_05 = {
            { 1, 2 },
            { 3, 4 },
            { 5, 6 },
        },
        field_06 = {
            {
                { { x=1, y="one", st={a=1,b=2} },
                  { x=2, y="two" },
                },
                { { x=-1 },
                  { y="N/A" },
                },
                { { z=0.1, st={a=3,b=4} },
                  { z=0.2 },
                },
            },
            {
                { { x=10, y="ten", arr={"a", "b"} },
                  { x=20, y="twenty" },
                },
                { { x=-2 },
                  { y="N/A" },
                },
                { { z=math.pi, arr={"cd", "efg"} },
                  { z=math.pi/2 },
                },
            },
            {
                { { s="", s2="---------------------------------------" },
                },
            },
            {
                { { t=true },
                },
            },
        }
    },

    SAME_NAME = "global",

    TABLE = {
        SAME_NAME = "field",
    },
}
