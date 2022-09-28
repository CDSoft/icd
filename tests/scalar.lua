return {
    pos = {
        a = 0,
        b = 1<<8 - 1,
        c = 1<<8,
        d = 1<<16 - 1,
        e = 1<<16,
        f = 1<<32 - 1,
        g = 1<<32,
        h = 1<<32 + 1,
    },
    neg = {
        a = -(1<<7),
        b = -(1<<15),
        c = -(1<<31),
        d = -(1<<63),
    },
    boolean = {
        t = true,
        f = false,
    },
    strings = {
        s1 = "",
        s2 = "hello",
        s3 = "hello world!",
    },

    floats = {
        f1 = 0.0,
        f2 = 1.0,
        f3 = 3.1,
        f4 = math.pi,
    },

    a = math.maxinteger,
    b = math.mininteger,
    b1 = math.mininteger+1,
    b2 = math.mininteger+2,
    b3 = math.mininteger+3,
    b4 = math.mininteger+4,
}
