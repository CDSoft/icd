module Structs
where
data TestsStructsFlatStructure = TestsStructsFlatStructure
    { flatStructureField1' :: Integer
    , flatStructureField2' :: String
    , flatStructureField3' :: Bool
    , flatStructureField4' :: Double
    }
data TestsStructsMegaStructField02 = TestsStructsMegaStructField02
    { megaStructField02X' :: Integer
    , megaStructField02Y' :: Integer
    }
data TestsStructsMegaStructField03 = TestsStructsMegaStructField03
    { megaStructField03A' :: String
    , megaStructField03B' :: Bool
    }
data TestsStructsMegaStructField06St = TestsStructsMegaStructField06St
    { megaStructField06StA' :: Integer
    , megaStructField06StB' :: Integer
    }
data TestsStructsMegaStructField06 = TestsStructsMegaStructField06
    { megaStructField06Arr' :: [String]
    , megaStructField06S' :: String
    , megaStructField06S2' :: String
    , megaStructField06St' :: TestsStructsMegaStructField06St
    , megaStructField06T' :: Bool
    , megaStructField06X' :: Integer
    , megaStructField06Y' :: String
    , megaStructField06Z' :: Double
    }
data TestsStructsMegaStruct = TestsStructsMegaStruct
    { megaStructField01' :: Integer
    , megaStructField02' :: TestsStructsMegaStructField02
    , megaStructField03' :: TestsStructsMegaStructField03
    , megaStructField04' :: [String]
    , megaStructField05' :: [[Integer]]
    , megaStructField06' :: [[[TestsStructsMegaStructField06]]]
    }
data TestsStructsTable = TestsStructsTable
    { tableSameName' :: String
    }
data TestsStructs = TestsStructs
    { flatArray' :: [Integer]
    , flatStructure' :: TestsStructsFlatStructure
    , megaStruct' :: TestsStructsMegaStruct
    , sameName' :: String
    , table' :: TestsStructsTable
    }
testsStructs :: TestsStructs
testsStructs = TestsStructs
    { flatArray' = [10, 20, 30, 40]
    , flatStructure' = TestsStructsFlatStructure {flatStructureField1' = 42, flatStructureField2' = "fourty two", flatStructureField3' = True, flatStructureField4' = 3.1415926535898}
    , megaStruct' = TestsStructsMegaStruct
        { megaStructField01' = 42
        , megaStructField02' = TestsStructsMegaStructField02 {megaStructField02X' = 0, megaStructField02Y' = 1}
        , megaStructField03' = TestsStructsMegaStructField03 {megaStructField03A' = "hi", megaStructField03B' = True}
        , megaStructField04' = ["one", "two", "three"]
        , megaStructField05' =
            [ [1, 2]
            , [3, 4]
            , [5, 6]
            ]
        , megaStructField06' =
            [
                [
                    [ TestsStructsMegaStructField06
                        { megaStructField06Arr' = []
                        , megaStructField06S' = ""
                        , megaStructField06S2' = ""
                        , megaStructField06St' = TestsStructsMegaStructField06St {megaStructField06StA' = 1, megaStructField06StB' = 2}
                        , megaStructField06T' = False
                        , megaStructField06X' = 1
                        , megaStructField06Y' = "one"
                        , megaStructField06Z' = 0.0
                        }
                    , TestsStructsMegaStructField06 {megaStructField06Arr' = [], megaStructField06S' = "", megaStructField06S2' = "", megaStructField06St' = TestsStructsMegaStructField06St {megaStructField06StA' = 0, megaStructField06StB' = 0}, megaStructField06T' = False, megaStructField06X' = 2, megaStructField06Y' = "two", megaStructField06Z' = 0.0}
                    ]
                ,
                    [ TestsStructsMegaStructField06 {megaStructField06Arr' = [], megaStructField06S' = "", megaStructField06S2' = "", megaStructField06St' = TestsStructsMegaStructField06St {megaStructField06StA' = 0, megaStructField06StB' = 0}, megaStructField06T' = False, megaStructField06X' = -1, megaStructField06Y' = "", megaStructField06Z' = 0.0}
                    , TestsStructsMegaStructField06 {megaStructField06Arr' = [], megaStructField06S' = "", megaStructField06S2' = "", megaStructField06St' = TestsStructsMegaStructField06St {megaStructField06StA' = 0, megaStructField06StB' = 0}, megaStructField06T' = False, megaStructField06X' = 0, megaStructField06Y' = "N/A", megaStructField06Z' = 0.0}
                    ]
                ,
                    [ TestsStructsMegaStructField06
                        { megaStructField06Arr' = []
                        , megaStructField06S' = ""
                        , megaStructField06S2' = ""
                        , megaStructField06St' = TestsStructsMegaStructField06St {megaStructField06StA' = 3, megaStructField06StB' = 4}
                        , megaStructField06T' = False
                        , megaStructField06X' = 0
                        , megaStructField06Y' = ""
                        , megaStructField06Z' = 0.1
                        }
                    , TestsStructsMegaStructField06 {megaStructField06Arr' = [], megaStructField06S' = "", megaStructField06S2' = "", megaStructField06St' = TestsStructsMegaStructField06St {megaStructField06StA' = 0, megaStructField06StB' = 0}, megaStructField06T' = False, megaStructField06X' = 0, megaStructField06Y' = "", megaStructField06Z' = 0.2}
                    ]
                ]
            ,
                [
                    [ TestsStructsMegaStructField06
                        { megaStructField06Arr' = ["a", "b"]
                        , megaStructField06S' = ""
                        , megaStructField06S2' = ""
                        , megaStructField06St' = TestsStructsMegaStructField06St {megaStructField06StA' = 0, megaStructField06StB' = 0}
                        , megaStructField06T' = False
                        , megaStructField06X' = 10
                        , megaStructField06Y' = "ten"
                        , megaStructField06Z' = 0.0
                        }
                    , TestsStructsMegaStructField06 {megaStructField06Arr' = [], megaStructField06S' = "", megaStructField06S2' = "", megaStructField06St' = TestsStructsMegaStructField06St {megaStructField06StA' = 0, megaStructField06StB' = 0}, megaStructField06T' = False, megaStructField06X' = 20, megaStructField06Y' = "twenty", megaStructField06Z' = 0.0}
                    ]
                ,
                    [ TestsStructsMegaStructField06 {megaStructField06Arr' = [], megaStructField06S' = "", megaStructField06S2' = "", megaStructField06St' = TestsStructsMegaStructField06St {megaStructField06StA' = 0, megaStructField06StB' = 0}, megaStructField06T' = False, megaStructField06X' = -2, megaStructField06Y' = "", megaStructField06Z' = 0.0}
                    , TestsStructsMegaStructField06 {megaStructField06Arr' = [], megaStructField06S' = "", megaStructField06S2' = "", megaStructField06St' = TestsStructsMegaStructField06St {megaStructField06StA' = 0, megaStructField06StB' = 0}, megaStructField06T' = False, megaStructField06X' = 0, megaStructField06Y' = "N/A", megaStructField06Z' = 0.0}
                    ]
                ,
                    [ TestsStructsMegaStructField06
                        { megaStructField06Arr' = ["cd", "efg"]
                        , megaStructField06S' = ""
                        , megaStructField06S2' = ""
                        , megaStructField06St' = TestsStructsMegaStructField06St {megaStructField06StA' = 0, megaStructField06StB' = 0}
                        , megaStructField06T' = False
                        , megaStructField06X' = 0
                        , megaStructField06Y' = ""
                        , megaStructField06Z' = 3.1415926535898
                        }
                    , TestsStructsMegaStructField06 {megaStructField06Arr' = [], megaStructField06S' = "", megaStructField06S2' = "", megaStructField06St' = TestsStructsMegaStructField06St {megaStructField06StA' = 0, megaStructField06StB' = 0}, megaStructField06T' = False, megaStructField06X' = 0, megaStructField06Y' = "", megaStructField06Z' = 1.5707963267949}
                    ]
                ]
            ,
                [
                    [ TestsStructsMegaStructField06 {megaStructField06Arr' = [], megaStructField06S' = "", megaStructField06S2' = "---------------------------------------", megaStructField06St' = TestsStructsMegaStructField06St {megaStructField06StA' = 0, megaStructField06StB' = 0}, megaStructField06T' = False, megaStructField06X' = 0, megaStructField06Y' = "", megaStructField06Z' = 0.0}
                    ]
                ]
            ,
                [
                    [ TestsStructsMegaStructField06 {megaStructField06Arr' = [], megaStructField06S' = "", megaStructField06S2' = "", megaStructField06St' = TestsStructsMegaStructField06St {megaStructField06StA' = 0, megaStructField06StB' = 0}, megaStructField06T' = True, megaStructField06X' = 0, megaStructField06Y' = "", megaStructField06Z' = 0.0}
                    ]
                ]
            ]
        }
    , sameName' = "global"
    , table' = TestsStructsTable {tableSameName' = "field"}
    }
