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

local utils = {}

local F = require "F"

F[[ lower_snake_case
    upper_snake_case
    lower_camel_case
    upper_camel_case
    dotted_lower_snake_case
    dotted_upper_snake_case
]]:words():foreach(function(conv)
    utils[conv] = function(...)
        return string[conv](F{...}:flatten(F.const(false)):str" ")
    end
end)

local function tb_level()
    local utils_source = debug.getinfo(1, "S").source
    local level = 0
    repeat
        level = level + 1
        local info = debug.getinfo(level, "S")
        if not info then return end
    until info.source ~= utils_source and info.source:match "^@[^$]"
    return level-1
end

local protected_environment = {
    __index = function(_, name)
        local level = tb_level()
        error(name..": undefined identifier", level)
    end,
    __newindex = function(_, name)
        local level = tb_level()
        error(name..": can not create new variables", level)
    end,
}

local protected_table = {
    __newindex = function(_, name)
        local level = tb_level()
        if type(name) == "number" then
            error("["..name.."]: can not add new items in arrays", level)
        else
            error(name..": can not create new fields in tables", level)
        end
    end,
}

local function protect(t)
    if type(t) == "table" then
        if getmetatable(t) == nil then setmetatable(t, protected_table) end
        for _, v in pairs(t) do
            if type(v) == "table" and getmetatable(v) == nil then protect(v) end
        end
    end
    return t
end

function utils.protect(env)
    return setmetatable(env, protected_environment)
end

local lua_require = require

local modules = {}

local function check_name_uniqueness(table_name, t)
    if type(t) ~= "table" then return end
    local simplified_names = {}
    for k, _ in F.pairs(t) do
        if type(k) == "string" then
            local simplified_name = k:gsub("_", ""):lower()
            simplified_names[simplified_name] = simplified_names[simplified_name] or {}
            table.insert(simplified_names[simplified_name], k)
        end
    end
    for _, actual_names in F.pairs(simplified_names) do
        if #actual_names > 1 then
            error(("Ambiguous names in %s: %s"):format(table_name, table.concat(actual_names, ", ")), 0)
        end
    end
end

local function protected_require(name)
    local protected = require ~= lua_require
    if not protected then require = protected_require end
    local t = protect(assert(lua_require(name)))
    check_name_uniqueness(name, t)
    modules[name] = modules[name] or F.deep_clone(t)
    if not protected then require = lua_require end
    return t
end

local function literal(x)
    return (type(x) == "string" and "%q" or "%s"):format(x)
end

local function path(name, field)
    if type(field) == "number" then return ("%s[%s]"):format(name, field) end
    return ("%s.%s"):format(name, field)
end

local function deep_compare(name, t1, t2)
    if type(t1) ~= "table" or type(t2) ~= "table" then
        if t1 ~= t2 then
            error(("%s: unexpected side effect (%s -> %s)"):format(name, literal(t1), literal(t2)), 0)
        end
    else
        for k, v1 in F.pairs(t1) do
            local v2 = rawget(t2, k)
            deep_compare(path(name, k), v1, v2)
        end
        for k, v2 in F.pairs(t2) do
            local v1 = rawget(t1, k)
            deep_compare(path(name, k), v1, v2)
        end
    end
end

local function check_side_effects()
    for name, initial_content in F.pairs(modules) do
        local new_content = lua_require(name)
        deep_compare(name, initial_content, new_content)
    end
end

function utils.require(name)
    local t = protected_require(name)
    check_side_effects()
    return t
end

return utils
