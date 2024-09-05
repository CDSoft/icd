--[[
This file is part of icd.

icd is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

icd is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with icd.  If not, see <https://www.gnu.org/licenses/>.

For further information about icd you can visit
http://gitlab.com/CDSoft/icd
]]

--@LIB=backend.sh

local backend = {}

local parser = require "parser"
local utils = require "utils"

local gen_const, gen_custom

local function gen_sh(ast, namespace)
    local s = "#!/bin/sh\n"
    s = s .. (parser.prelude(ast, "sh") or "")
    parser.leaves(ast, function(path, x, t)
        local name = utils.upper_snake_case(namespace, path)
        local val = gen_const(x, t, path)
        if val ~= nil then
            s = s .. "export " .. name .. "=" .. val .. "\n"
        end
    end)
    return s
end

gen_const = function(x, t, path)
    path = path or {}
    if t.kind == "uint" then return tostring(x) end
    if t.kind == "int" then return tostring(x) end
    if t.kind == "bool" then return tostring(x) end
    if t.kind == "double" then return tostring(x) end
    if t.kind == "str" then return '"'..tostring(x)..'"' end
    if t.kind == "custom" then return gen_custom(x, t) end
    error("Unknown value: " .. utils.dump(t))
end

gen_custom = function(x, t)
    local defs = t.definitions.sh
    if defs then
        return (defs.v or "%s"):format(x[1])
    end
end

function backend.compile(output, ast, namespace)
    return {
        {"sh", gen_sh(ast, namespace)},
    }
end

return backend
