module Import
where
data TestsImportImportedLib = TestsImportImportedLib
    { importedLibArrayFromImportedLib' :: [String]
    , importedLibParameterFromImportedLib' :: Integer
    }
data TestsImport = TestsImport
    { importedLib' :: TestsImportImportedLib
    , importedParameter' :: Integer
    }
testsImport :: TestsImport
testsImport = TestsImport
    { importedLib' = TestsImportImportedLib
        { importedLibArrayFromImportedLib' = ["a", "b"]
        , importedLibParameterFromImportedLib' = 21
        }
    , importedParameter' = 42
    }
