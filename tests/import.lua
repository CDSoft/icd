local lib = require "tests/lib/lib"

local F = require "F"

return {
    IMPORTED_PARAMETER = lib.PARAMETER_FROM_IMPORTED_LIB*2,
    IMPORTED_LIB = lib,
    array = F.range(10):map(function(x) return x*x end),
}
