module Import
where
data TestsImportImportedLib = TestsImportImportedLib
    { importedLibArrayFromImportedLib' :: [String]
    , importedLibParameterFromImportedLib' :: Integer
    }
data TestsImport = TestsImport
    { importedLib' :: TestsImportImportedLib
    , importedParameter' :: Integer
    , array' :: [Integer]
    }
testsImport :: TestsImport
testsImport = TestsImport
    { importedLib' = TestsImportImportedLib
        { importedLibArrayFromImportedLib' = ["a", "b"]
        , importedLibParameterFromImportedLib' = 21
        }
    , importedParameter' = 42
    , array' = [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
    }
