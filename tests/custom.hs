module Custom
where
data State = INIT | RUNNING | DEAD
data TestsCustomCompoundCustomPoints = TestsCustomCompoundCustomPoints
    { compoundCustomPointsX' :: Integer
    , compoundCustomPointsY' :: Integer
    }
data TestsCustomCompoundCustom = TestsCustomCompoundCustom
    { compoundCustomN' :: Integer
    , compoundCustomPoints' :: [TestsCustomCompoundCustomPoints]
    }
data TestsCustom = TestsCustom
    { compoundCustom' :: TestsCustomCompoundCustom
    , f' :: String
    , hellostr' :: String
    , initialState' :: State
    , myPtr' :: Int
    , running' :: State
    }
testsCustom :: TestsCustom
testsCustom = TestsCustom
    { compoundCustom' = TestsCustomCompoundCustom
        { compoundCustomN' = 3
        , compoundCustomPoints' =
            [ TestsCustomCompoundCustomPoints {compoundCustomPointsX' = 1, compoundCustomPointsY' = 2}
            , TestsCustomCompoundCustomPoints {compoundCustomPointsX' = 3, compoundCustomPointsY' = 4}
            , TestsCustomCompoundCustomPoints {compoundCustomPointsX' = 5, compoundCustomPointsY' = 6}
            ]
        }
    , f' = "fib"
    , hellostr' = "Hello World!"
    , initialState' = INIT
    , myPtr' = 0x00001234
    , running' = RUNNING
    }
