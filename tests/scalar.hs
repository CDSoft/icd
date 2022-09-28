module Scalar
where
data TestsScalarBoolean = TestsScalarBoolean
    { booleanF' :: Bool
    , booleanT' :: Bool
    }
data TestsScalarFloats = TestsScalarFloats
    { floatsF1' :: Double
    , floatsF2' :: Double
    , floatsF3' :: Double
    , floatsF4' :: Double
    }
data TestsScalarNeg = TestsScalarNeg
    { negA' :: Integer
    , negB' :: Integer
    , negC' :: Integer
    , negD' :: Integer
    }
data TestsScalarPos = TestsScalarPos
    { posA' :: Integer
    , posB' :: Integer
    , posC' :: Integer
    , posD' :: Integer
    , posE' :: Integer
    , posF' :: Integer
    , posG' :: Integer
    , posH' :: Integer
    }
data TestsScalarStrings = TestsScalarStrings
    { stringsS1' :: String
    , stringsS2' :: String
    , stringsS3' :: String
    }
data TestsScalar = TestsScalar
    { a' :: Integer
    , b' :: Integer
    , b1' :: Integer
    , b2' :: Integer
    , b3' :: Integer
    , b4' :: Integer
    , boolean' :: TestsScalarBoolean
    , floats' :: TestsScalarFloats
    , neg' :: TestsScalarNeg
    , pos' :: TestsScalarPos
    , strings' :: TestsScalarStrings
    }
testsScalar :: TestsScalar
testsScalar = TestsScalar
    { a' = 9223372036854775807
    , b' = -9223372036854775808
    , b1' = -9223372036854775807
    , b2' = -9223372036854775806
    , b3' = -9223372036854775805
    , b4' = -9223372036854775804
    , boolean' = TestsScalarBoolean {booleanF' = False, booleanT' = True}
    , floats' = TestsScalarFloats {floatsF1' = 0.0, floatsF2' = 1.0, floatsF3' = 3.1, floatsF4' = 3.1415926535898}
    , neg' = TestsScalarNeg {negA' = -128, negB' = -32768, negC' = -2147483648, negD' = -9223372036854775808}
    , pos' = TestsScalarPos {posA' = 0, posB' = 128, posC' = 256, posD' = 32768, posE' = 65536, posF' = 2147483648, posG' = 4294967296, posH' = 8589934592}
    , strings' = TestsScalarStrings {stringsS1' = "", stringsS2' = "hello", stringsS3' = "hello world!"}
    }
