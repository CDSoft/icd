local lib = require "tests/lib/lib"

return {
    IMPORTED_PARAMETER = lib.PARAMETER_FROM_IMPORTED_LIB*2,
    IMPORTED_LIB = lib,
}
