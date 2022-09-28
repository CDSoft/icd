module Import
where
data TestsImportImportedLib = TestsImportImportedLib
    { importedLibParameterFromImportedLib' :: Integer
    }
data TestsImport = TestsImport
    { importedLib' :: TestsImportImportedLib
    , importedParameter' :: Integer
    }
testsImport :: TestsImport
testsImport = TestsImport
    { importedLib' = TestsImportImportedLib {importedLibParameterFromImportedLib' = 21}
    , importedParameter' = 42
    }
