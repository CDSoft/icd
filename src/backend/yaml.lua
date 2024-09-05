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

--@LIB=backend.yaml

local backend = {}

local utils = require "utils"

local F = require "F"

local gen_const, gen_struct, gen_array, gen_custom

gen_const = function(x, t, namespace, path, indent, indent_first)
    path = path or {}
    indent = indent or ""
    if t.kind == "struct" then return gen_struct(x, t, namespace, path, indent, indent_first) end
    if t.kind == "array" then return gen_array(x, t, namespace, path, indent) end
    if t.kind == "uint" then return tostring(x) end
    if t.kind == "int" then return tostring(x) end
    if t.kind == "bool" then return tostring(x) end
    if t.kind == "double" then return tostring(x) end
    if t.kind == "str" then return '"'..tostring(x)..'"' end
    if t.kind == "custom" then return gen_custom(x, t) end
    error("Unknown value: " .. utils.dump(t))
end

gen_custom = function(x, t)
    local defs = t.definitions.yaml
    if defs then
        return (defs.v or "%s"):format(x[1])
    end
end

gen_struct = function(x, t, namespace, path, indent, indent_first)
    local indent2 = indent.."  "
    local s = indent_first and "\n" or ""
    local indent_next = indent_first
    for fieldname, fieldtype in F.pairs(t.fields) do
        local path2 = F.concat{path, {fieldname}}
        if x[fieldname] ~= nil then
            local const = gen_const(x[fieldname], fieldtype, namespace, path2, indent2, true)
            if const ~= nil then
                if indent_next then
                    s = s..indent
                end
                indent_next = true
                s = s..utils.lower_snake_case(fieldname)..": "
                s = s..const
                s = s.."\n"
            end
        end
    end
    return s
end

gen_array = function(x, t, namespace, path, indent)
    local s = "\n"
    for i = 1, #x do
        s = s..indent.."- "
        s = s..gen_const(x[i], t.itemtype, namespace, path, indent.."  ", false).."\n"
    end
    s = s.."\n"
    return s
end

local function gen_yaml(ast, namespace)
    local s = "---\n"
    s = s .. namespace..":\n"
    s = s .. gen_const(ast, ast.__type, namespace, {}, "  ", true)
    s = s .. "...\n"
    return s
end

local function clean(s)
    s = s:gsub("%s+\n", "\n")
    s = s:gsub("\n+", "\n")
    return s
end

function backend.compile(output, ast, namespace)
    return {
        {"yaml", clean(gen_yaml(ast, namespace))},
    }
end

return backend
