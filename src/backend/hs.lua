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
http://codeberg.org/cdsoft/icd
]]

--@LIB=backend.hs

local backend = {}

local utils = require "utils"
local parser = require "parser"

local F = require "F"
local fs = require "fs"

local gen_type, gen_struct_type, gen_array_type, gen_custom_type

local structs = {}

gen_type = function(t, namespace, path)
    path = path or {}
    if t.kind == "struct" then return gen_struct_type(t, namespace, path) end
    if t.kind == "array" then return gen_array_type(t, namespace, path) end
    if t.kind == "uint" then return "%s :: Integer" end
    if t.kind == "int" then return "%s :: Integer" end
    if t.kind == "bool" then return "%s :: Bool" end
    if t.kind == "double" then return "%s :: Double" end
    if t.kind == "str" then return "%s :: String" end
    if t.kind == "custom" then return gen_custom_type(t) end
    error("Unknown type: " .. utils.dump(t))
end

gen_custom_type = function(t)
    local defs = t.definitions.hs
    if defs then
        return defs.t
    end
end

gen_struct_type = function(t, namespace, path)
    local name = utils.upper_camel_case(namespace, path)
    local s = "data "..name.." = "..name.."\n"
    local coma = "    {"
    for fieldname, fieldtype in F.pairs(t.fields) do
        local path2 = F.concat{path, {fieldname}}
        local type = gen_type(fieldtype, namespace, path2)
        if type ~= nil then
            s = s..(type:format(coma.." "..utils.lower_camel_case(path, fieldname).."'")).."\n"
            coma = "    ,"
        end
    end
    s = s.."    }\n"
    table.insert(structs, {name, s})
    return "%s :: "..name
end

gen_array_type = function(t, namespace, path)
    local item_decl = gen_type(t.itemtype, namespace, path)
    local name, item_type = item_decl:match "(.*) :: (.*)"
    return name.." :: ["..item_type.."]"
end

local gen_const, gen_struct, gen_array, gen_custom

local function gen_types(output, ast, namespace)
    local module_name = utils.upper_camel_case((fs.basename(output):splitext()))
    local const_name = utils.lower_camel_case(namespace)
    local s = "module "..module_name.."\nwhere\n"
    s = s .. (parser.prelude(ast, "hs") or "")
    local main_type = (gen_type(ast.__type, namespace):format(const_name))
    for i = 1, #structs do
        s = s .. structs[i][2]
    end
    s = s .. main_type .. "\n"
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

gen_const = function(x, t, namespace, path, indent)
    path = path or {}
    indent = indent or ""
    if t.kind == "struct" then return gen_struct(x, t, namespace, path, indent) end
    if t.kind == "array" then return gen_array(x, t, namespace, path, indent) end
    if t.kind == "uint" then return tostring(x or 0) end
    if t.kind == "int" then return tostring(x or 0) end
    if t.kind == "bool" then return utils.upper_camel_case(tostring(x or false)) end
    if t.kind == "double" then return tostring(x or 0.0) end
    if t.kind == "str" then return '"'..tostring(x or "")..'"' end
    if t.kind == "custom" then return gen_custom(x, t) end
    error("Unknown value: " .. utils.dump(t))
end

gen_custom = function(x, t)
    local defs = t.definitions.hs
    if defs then
        return (defs.v or "%s"):format(x[1])
    end
end

gen_struct = function(x, t, namespace, path, indent)
    local name = utils.upper_camel_case(namespace, path)
    local multiline = x and multiline_struct(path, x, t)
    local nl = multiline and "\n" or ""
    local indent2 = multiline and (indent.."    ") or ""
    local s = name.." "..nl
    local sep = multiline and "{ " or "{"
    for fieldname, fieldtype in F.pairs(t.fields) do
        local path2 = F.concat{path, {fieldname}}
        local const = gen_const(x and x[fieldname], fieldtype, namespace, path2, indent2)
        if const ~= nil then
            s = s..indent2..sep..utils.lower_camel_case(path, fieldname).."' = "
            s = s..const
            s = s..nl
            sep = ", "
        end
    end
    s = s..(multiline and indent2 or "").."}"
    return s
end

gen_array = function(x, t, namespace, path, indent)
    if x == nil then return "[]" end
    local multiline = multiline_struct(path, x, t)
    local nl = multiline and "\n" or ""
    local indent2 = multiline and (indent.."    ") or ""
    local s = nl
    local sep = multiline and "[ " or "["
    for i = 1, #x do
        s = s..indent2..sep..gen_const(x[i], t.itemtype, namespace, path, indent2)..nl
        sep = ", "
    end
    s = s..(multiline and indent2 or "").."]"
    return s
end

local function gen_constants(ast, namespace)
    local s = utils.lower_camel_case(namespace).." = "
    s = s .. gen_const(ast, ast.__type, namespace).."\n"
    return s
end

local function clean(s)
    s = s:gsub(" +\n", "\n")
    return s
end

local function gen_hs(output, ast, namespace)
    local s = gen_types(output, ast, namespace)
    s = s .. gen_constants(ast, namespace)
    return s
end

function backend.compile(output, ast, namespace)
    return {
        {"hs", clean(gen_hs(output, ast, namespace))},
    }
end

return backend
