--[[
This file is part of ldc.

ldc is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

ldc is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with ldc.  If not, see <https://www.gnu.org/licenses/>.

For further information about ldc you can visit
http://codeberg.org/cdsoft/ldc
]]

--@LIB=backend.c

local backend = {}

local parser = require "parser"
local utils = require "utils"

local F = require "F"
local fs = require "fs"

local gen_type, gen_struct_type, gen_array_type, gen_custom_type, gen_string_type, gen_ctype

gen_type = function(t, namespace, path, indent)
    path = path or {}
    indent = indent or ""
    if t.ctype then return gen_ctype(t, indent) end
    if t.kind == "struct" then return gen_struct_type(t, namespace, path, indent) end
    if t.kind == "array" then return gen_array_type(t, namespace, path, indent) end
    if t.kind == "uint" then return indent.."uint"..t.size.."_t %s" end
    if t.kind == "int" then return indent.."int"..t.size.."_t %s" end
    if t.kind == "bool" then return indent.."bool %s" end
    if t.kind == "double" then return indent.."double %s" end
    if t.kind == "str" then return gen_string_type(t, namespace, path, indent) end
    if t.kind == "custom" then return gen_custom_type(t, indent) end
    error("Unknown type: " .. utils.dump(t))
end

gen_string_type = function(t, namespace, path, indent)
    local len_name = utils.upper_snake_case(namespace, path, "LEN")
    local s = "#define "..len_name.." "..(t.size+1).."\n"
    s = s .. indent.."char %s["..len_name.."]"
    return s
end

gen_ctype = function(t, indent)
    return indent..t.ctype.." %s"
end

gen_custom_type = function(t, indent)
    local defs = t.definitions.c
    if defs then
        return indent..defs.t
    end
end

gen_struct_type = function(t, namespace, path, indent)
    local s = indent.."struct "..utils.lower_snake_case("t", namespace, path).."\n"
    s = s..indent.."{\n"
    for fieldname, fieldtype in F.pairs(t.fields) do
        local path2 = F.concat{path, {fieldname}}
        local type = gen_type(fieldtype, namespace, path2, indent.."    ")
        if type ~= nil then
            s = s..(type:format(utils.lower_snake_case(fieldname)))..";\n"
        end
    end
    s = s..indent.."} %s"
    return s
end

gen_array_type = function(t, namespace, path, indent)
    local size_name = utils.upper_snake_case(namespace, path, ("SIZE%d"):format(t.dim))
    local s = "#define "..size_name.." "..t.size.."\n"
    s = s .. gen_type(t.itemtype, namespace, path, indent):format("%s["..size_name.."]")
    return s
end

local gen_const, gen_struct, gen_array, gen_custom

local function gen_h(ast, namespace, params)
    local s = "#pragma once\n"
    s = s .. "#include <stdbool.h>\n"
    s = s .. "#include <stdint.h>\n"
    s = s .. (parser.prelude(ast, "c") or "")
    if params.cpp_const then
        parser.leaves(ast, function(path, x, t)
            local name = utils.upper_snake_case(namespace, path)
            local val = gen_const(x, t, namespace, path)
            if val ~= nil then
                s = s .. "#define " .. name .. " (" .. val .. ")\n"
            end
        end)
    end
    s = s .. (gen_type(ast.__type, namespace):format("")) .. ";\n"
    s = s .. "extern const struct "..utils.lower_snake_case("t", namespace).." "..utils.upper_snake_case(namespace)..";\n"
    return s
end

local function depth(x, t)
    local d = 0
    if t.kind == "array" then
        for i = 1, #x do
            d = math.max(d, 1+depth(x[i], t.itemtype))
        end
    elseif t.kind == "struct" then
        for fieldname, fieldtype in F.pairs(t.fields) do
            if x[fieldname] ~= nil then
                d = math.max(d, 1+depth(x[fieldname], fieldtype))
            end
        end
    end
    return d
end

local function multiline_struct(path, x, t)
    return #path < 1 or depth(x, t) > 1
end

local function uint_suffix(size)
    local suffix = {
        [8] = "",
        [16] = "",
        [32] = "",
        [64] = "LLU",
    }
    return suffix[size] or ""
end

local function int_suffix(size)
    local suffix = {
        [8] = "",
        [16] = "",
        [32] = "",
        [64] = "LL",
    }
    return suffix[size] or ""
end

local function uinttostring(x, size)
    local p = uint_suffix(size)
    return ("%s%s"): format(x, p)
end

local function inttostring(x, size)
    local p = int_suffix(size)
    if x == math.mininteger then
        return ("%s%s-1%s"):format(x+1, p, p)
    else
        return ("%s%s"): format(x, p)
    end
end

gen_const = function(x, t, namespace, path, indent)
    path = path or {}
    indent = indent or ""
    if t.kind == "struct" then return gen_struct(x, t, namespace, path, indent) end
    if t.kind == "array" then return gen_array(x, t, namespace, path, indent) end
    if t.kind == "uint" then return uinttostring(x, t.size) end
    if t.kind == "int" then return inttostring(x, t.size) end
    if t.kind == "bool" then return tostring(x) end
    if t.kind == "double" then return tostring(x) end
    if t.kind == "str" then return '"'..tostring(x)..'"' end
    if t.kind == "custom" then return gen_custom(x, t) end
    error("Unknown type: " .. utils.dump(t))
end

gen_custom = function(x, t)
    local defs = t.definitions.c
    if defs then
        return (defs.v or "%s"):format(x[1])
    end
end

gen_struct = function(x, t, namespace, path, indent)
    local multiline = multiline_struct(path, x, t)
    local nl = multiline and "\n" or ""
    local indent2 = multiline and (indent.."    ") or ""
    local s = "{"..nl
    for fieldname, fieldtype in F.pairs(t.fields) do
        local path2 = F.concat{path, {fieldname}}
        if x[fieldname] ~= nil then
            local const = gen_const(x[fieldname], fieldtype, namespace, path2, indent2)
            if const ~= nil then
                s = s..indent2.."."..utils.lower_snake_case(fieldname).." = "
                s = s..const
                s = s..", "..nl
            end
        end
    end
    s = s..(multiline and indent or "").."}"
    return s
end

gen_array = function(x, t, namespace, path, indent)
    local multiline = multiline_struct(path, x, t)
    local nl = multiline and "\n" or ""
    local indent2 = multiline and (indent.."    ") or ""
    local s = "{"..nl
    for i = 1, #x do
        s = s..indent2.."["..(i-1).."] = "..gen_const(x[i], t.itemtype, namespace, path, indent2)..", "..nl
    end
    s = s..(multiline and indent or "").."}"
    return s
end

local function gen_c(output, ast, namespace)
    local s = "#include \""..fs.basename(output:gsub("%.[^%.]+$", ""))..".h\"\n"
    s = s .. "const struct "..utils.lower_snake_case("t", namespace).." "..utils.upper_snake_case(namespace).." = "
    s = s .. gen_const(ast, ast.__type, namespace)
    s = s .. ";\n"
    return s
end

local function clean(s)
    s = s:gsub(", }", "}")
    s = s:gsub(" +\n", "\n")
    s = s:gsub("} ;", "};")
    return s
end

function backend.compile(output, ast, namespace, params)
    return {
        {"c", clean(gen_c(output, ast, namespace))},
        {"h", clean(gen_h(ast, namespace, params))},
    }
end

return backend
