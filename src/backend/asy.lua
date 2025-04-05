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

--@LIB=backend.asy

local backend = {}

local utils = require "utils"
local parser = require "parser"

local F = require "F"

local gen_type, gen_struct_type, gen_array_type, gen_custom_type

local structs = {}

gen_type = function(t, namespace, path)
    path = path or {}
    local asy_type
    if t.kind == "struct" then asy_type = gen_struct_type(t, namespace, path) end
    if t.kind == "array" then asy_type = gen_array_type(t, namespace, path) end
    if t.kind == "uint" then asy_type = "int %s" end
    if t.kind == "int" then asy_type = "int %s" end
    if t.kind == "bool" then asy_type = "bool %s" end
    if t.kind == "double" then asy_type = "real %s" end
    if t.kind == "str" then asy_type = "string %s" end
    if t.kind == "custom" then asy_type = gen_custom_type(t) end
    if asy_type then
        t.asy_type = asy_type
        return asy_type
    else
        error("Unknown type: " .. utils.dump(t))
    end
end

gen_custom_type = function(t)
    local defs = t.definitions.asy
    if defs then
        return defs.t
    end
end

gen_struct_type = function(t, namespace, path)
    local name = utils.lower_snake_case("t", namespace, path)
    local s = "struct "..name.." {\n"
    for fieldname, fieldtype in F.pairs(t.fields) do
        local path2 = F.concat{path, {fieldname}}
        local type = gen_type(fieldtype, namespace, path2)
        if type ~= nil then
            s = s.."    "..(type:format(utils.lower_snake_case(fieldname)))..";\n"
        end
    end
    s = s.."}\n"
    table.insert(structs, {name, s})
    return name.." %s"
end

gen_array_type = function(t, namespace, path)
    local item_type = gen_type(t.itemtype, namespace, path)
    return item_type:format("[]%s")
end

local function gen_types(ast, namespace)
    local const_name = utils.lower_snake_case(namespace)
    local s = parser.prelude(ast, "asy") or ""
    local main_type = (gen_type(ast.__type, namespace):format(const_name))
    for i = 1, #structs do
        s = s .. structs[i][2]
    end
    s = s .. main_type .. ";\n"
    return s
end

local gen_const, gen_struct, gen_array, gen_custom

local function full_path(...)
    local s = ""
    local function add_component(component)
        if type(component) == "string" then
            if s == "" then
                s = component
            else
                s = s.."."..utils.lower_snake_case(component)
            end
        elseif type(component) == "number" then
            s = s.."["..utils.lower_snake_case(tostring(component)).."]"
        else
            error("invalid component: "..tostring(component))
        end
    end
    local function add_components(components)
        for _, field in ipairs(components) do
            add_component(field)
        end
    end
    for i = 1, select("#", ...) do
        local name = select(i, ...)
        if type(name) == "table" then
            add_components(name)
        else
            add_component(name)
        end
    end
    return s
end

local function inttostring(x)
    local smallest = math.mininteger + 4
    if x < smallest then
        return ("%s-%s"):format(smallest, smallest-x)
    else
        return tostring(x)
    end
end

gen_const = function(x, t, namespace, path)
    path = path or {}
    local name = full_path(namespace, path)
    if t.kind == "struct" then return gen_struct(x, t, namespace, path) end
    if t.kind == "array" then return gen_array(x, t, namespace, path) end
    if t.kind == "uint" then return name.." = "..tostring(x)..";\n" end
    if t.kind == "int" then return name.." = "..inttostring(x)..";\n" end
    if t.kind == "bool" then return name.." = "..tostring(x)..";\n" end
    if t.kind == "double" then return name.." = "..tostring(x)..";\n" end
    if t.kind == "str" then return name.." = "..'"'..tostring(x)..'"'..";\n" end
    if t.kind == "custom" then return gen_custom(x, t, namespace, path) end
    error("Unknown value: " .. utils.dump(t))
end

gen_custom = function(x, t, namespace, path)
    local defs = t.definitions.asy
    if defs then
        local name = full_path(namespace, path)
        return name.." = "..(defs.v or "%s"):format(x[1])..";\n"
    end
end

gen_struct = function(x, t, namespace, path)
    local s = ""
    for fieldname, fieldtype in F.pairs(t.fields) do
        if x[fieldname] ~= nil then
            local path2 = F.concat{path, {fieldname}}
            local const = gen_const(x[fieldname], fieldtype, namespace, path2)
            if const ~= nil then
                s = s..const
            end
        end
    end
    return s
end

gen_array = function(x, t, namespace, path)
    local s = ""
    for i = 1, #x do
        if t.itemtype.kind == "struct" or t.itemtype.kind == "array" then
            local constructor = t.itemtype.asy_type:format("")
            s = s..full_path(namespace, path, i).." = new "..constructor..";\n"
        end
        local path2 = F.concat{path, {i}}
        local const = gen_const(x[i], t.itemtype, namespace, path2)
        s = s..const
    end
    return s
end

local function gen_constants(ast, namespace)
    return gen_const(ast, ast.__type, namespace).."\n"
end

local function gen_asy(ast, namespace)
    local s = gen_types(ast, namespace)
    s = s .. gen_constants(ast, namespace)
    return s
end

function backend.compile(output, ast, namespace)
    return {
        {"asy", gen_asy(ast, namespace)},
    }
end

return backend
