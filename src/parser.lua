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

local parser = {}

local utils = require "utils"

local F = require "F"
local fs = require "fs"

-- always sort table keys (variables must always be generated in the same order)
local pairs = F.pairs

local function is_scalar(t)
    return type(t) == "boolean" or type(t) == "number" or type(t) == "string"
end

local function is_array(t)
    if type(t) == "table" and not t.__custom then
        for _, _ in ipairs(t) do return true end
    end
end

local function is_struct(t)
    if type(t) == "table" and not t.__custom then
        for k, _ in pairs(t) do
            if type(k) == "string" then return true end
        end
    end
end

local function is_custom(t)
    return type(t) == "table" and t.__custom
end

local function is_hybrid(t)
    return is_array(t) and is_struct(t)
end

local function dump_path(path)
    local s = ""
    for _, comp in ipairs(path) do
        if type(comp) == "number" then s = s .. "[" .. comp .. "]"
        else s = s .. "." .. comp
        end
    end
    return s
end

local pathmt = {__tostring = dump_path}

local function add_path(path, comp)
    local path2 = F.concat{path, {comp}}
    return setmetatable(path2, pathmt)
end

--[[
local function merge(t1, t2)
    t1 = t1 or {}
    for k, v in pairs(t2) do t1[k] = v end
    return t1
end
--]]

local function build_custom(x)
    -- A custom typed value is defined in pure Lua script as {__custom=custom_type_def, value}
    -- build_custom adds a type definition in x.__type (as for other builtin types)
    if type(x) == "table" and type(x.__custom) == "table" then
        rawset(x, "__type", F.patch(x.__type, { kind = "custom", definitions = x.__custom }))
        x.__custom = true
    end
    if type(x) == "table" and type(x.__ctype) == "string" then
        rawset(x, "__type", F.patch(x.__type, { ctype = x.__ctype }))
    end
end

local add_types, add_scalar_type, add_array_type, add_struct_type, add_custom_type

add_types = function(x, path, dim)
    path = path or setmetatable({}, pathmt)
    build_custom(x)
    if is_hybrid(x) then error("Hybrid table: " .. tostring(path) .. " = " .. utils.dump(x))
    elseif is_array(x) then return add_array_type(x, path, dim)
    elseif is_struct(x) then return add_struct_type(x, path)
    elseif is_scalar(x) then return add_scalar_type(x, path)
    elseif is_custom(x) then return add_custom_type(x)
    else error("Invalid parameter: " .. tostring(path) .. " = " .. utils.dump(x))
    end
end

add_scalar_type = function(x, path)
    if type(x) == "boolean" then return {kind="bool"}
    elseif type(x) == "number" then
        if math.type(x) == "integer" then
            if 0 <= x and x < 1<<8 then return {kind="uint", size=8}
            elseif -(1<<7) <= x and x < 1<<7 then return {kind="int", size=8}
            elseif 0 <= x and x < 1<<16 then return {kind="uint", size=16}
            elseif -(1<<15) <= x and x < 1<<15 then return {kind="int", size=16}
            elseif 0 <= x and x < 1<<32 then return {kind="uint", size=32}
            elseif -(1<<31) <= x and x < 1<<31 then return {kind="int", size=32}
            elseif 0 <= x then return {kind="uint", size=64}
            else return {kind="int", size=64}
            end
        else return {kind="double"}
        end
    elseif type(x) == "string" then return {kind="str", size=#x}
    else error("Unknown scala type: " .. tostring(path) .. " = " .. utils.dump(x))
    end
end

add_custom_type = function(x)
    return x.__type
end

local merge_types, merge_array_types, merge_struct_types

merge_types = function(t1, t2, path)
    if not t1 then return t2 end
    if not t2 then return t1 end
    if t1.kind == "bool" and t2.kind == "bool" then return t1 end
    if t1.kind == "uint" and t2.kind == "uint" then return {kind="uint", size=math.max(t1.size, t2.size)} end
    if t1.kind == "int" and t2.kind == "int" then return {kind="int", size=math.max(t1.size, t2.size)} end
    if t1.kind == "uint" and t2.kind == "int" then return {kind="int", size=math.max(t1.size, t2.size)} end
    if t1.kind == "int" and t2.kind == "uint" then return {kind="int", size=math.max(t1.size, t2.size)} end
    if t1.kind == "double" and t2.kind == "double" then return t1 end
    if t1.kind == "str" and t2.kind == "str" then return {kind="str", size=math.max(t1.size, t2.size)} end
    if t1.kind == "array" and t2.kind == "array" then return merge_array_types(t1, t2, path) end
    if t1.kind == "struct" and t2.kind == "struct" then return merge_struct_types(t1, t2) end
    error("Can not merge types in " .. tostring(path))
end

merge_array_types = function(t1, t2, path)
    return {kind="array", size=math.max(t1.size, t2.size), itemtype=merge_types(t1.itemtype, t2.itemtype, path), dim=t1.dim}
end

merge_struct_types = function(t1, t2)
    local t = {kind="struct", fields={}}
    for k, v in pairs(t1.fields) do t.fields[k] = merge_types(t.fields[k], v) end
    for k, v in pairs(t2.fields) do t.fields[k] = merge_types(t.fields[k], v) end
    return t
end

add_array_type = function(x, path, dim)
    -- all items have the same type
    dim = (dim or 0) + 1
    rawset(x, "__type", F.patch(x.__type, {kind="array", size=#x, itemtype=nil, dim=dim}))
    for i, v in ipairs(x) do
        local path2 = add_path(path, i)
        local itemtype = add_types(v, path2, dim)
        x.__type.itemtype = merge_types(x.__type.itemtype, itemtype, path2)
    end
    return x.__type
end

local function filter(k, v)
    if k:match"^__" then return false end
    if type(v) == "function" then return false end
    return true
end

add_struct_type = function(x, path)
    -- each field has its own type
    rawset(x, "__type", F.patch(x.__type, {kind="struct", fields={}}))
    for k, v in pairs(x) do
        if filter(k, v) then
            local path2 = add_path(path, k)
            local field_type = add_types(v, path2)
            x.__type.fields[k] = field_type
        end
    end
    return x.__type
end

function parser.compile(ast)
    add_types(ast)
    return ast
end

function parser.prelude(ast, backend)
    if type(ast) == "table" then
        local prelude = {}
        if ast.__prelude and type(ast.__prelude) == "table" and ast.__prelude[backend] then
            table.insert(prelude, ast.__prelude[backend])
        end
        for _, v in pairs(ast) do
            local k_prelude = parser.prelude(v, backend)
            if k_prelude then table.insert(prelude, k_prelude) end
        end
        if #prelude > 0 then
            return table.concat(prelude, "\n").."\n"
        end
    end
end

function parser.leaves(x, f, path, t)
    path = path or setmetatable({}, pathmt)
    if type(x) == "table" and x.__type.kind == "array" then
        for i, v in ipairs(x) do
            local path2 = add_path(path, i-1)
            parser.leaves(v, f, path2, x.__type.itemtype)
        end
    elseif type(x) == "table" and x.__type.kind == "struct" then
        for k, v in pairs(x) do
            if filter(k, v) then
                local path2 = add_path(path, k)
                parser.leaves(v, f, path2, x.__type.fields[k])
            end
        end
    elseif type(x) == "table" and x.__type.kind == "custom" then
        f(path, x, t)
    elseif type(x) ~= "table" then
        f(path, x, t)
    end
end

function parser.save_dependencies(depfile, input, targets)
    fs.write(depfile, {
        F.unwords(targets), ": ",
        F.flatten { input, F.values(package.modpath) } : unwords(),
        "\n",
    })
end

return parser
