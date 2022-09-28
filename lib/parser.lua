local parser = {}

local utils = require "utils"

-- always sort table keys (variables must always be generated in the same order)
local pairs = utils.pairs

local lib_dir = utils.dirname(debug.getinfo(1, "S").source:sub(2))

local function get_deps()
    local deps = {}
    for name, _ in pairs(package.loaded) do
        local path = package.searchpath(name, package.path)
        if path and utils.dirname(path) ~= lib_dir then
            deps[path] = true
        end
    end
    local dep_list = {}
    for name, _ in pairs(deps) do
        table.insert(dep_list, name)
    end
    return dep_list
end

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
    local path2 = utils.append(path, comp)
    return setmetatable(path2, pathmt)
end

local function merge(t1, t2)
    t1 = t1 or {}
    for k, v in pairs(t2) do t1[k] = v end
    return t1
end

local function build_custom(x)
    -- A custom typed value is defined in pure Lua script as {__custom=custom_type_def, value}
    -- build_custom adds a type definition in x.__type (as for other builtin types)
    if type(x) == "table" and type(x.__custom) == "table" then
        x.__type = merge(x.__type, { kind = "custom", definitions = x.__custom })
        x.__custom = true
    end
    if type(x) == "table" and type(x.__ctype) == "string" then
        x.__type = merge(x.__type, { ctype = x.__ctype })
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
    x.__type = merge(x.__type, {kind="array", size=#x, itemtype=nil, dim=dim})
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
    x.__type = merge(x.__type, {kind="struct", fields={}})
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

function parser.leaves(x, f, path, t)
    path = path or setmetatable({}, pathmt)
    if type(x) == "table" and x.__type.kind == "array" then
        for i, v in ipairs(x) do
            local path2 = add_path(path, i)
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

function parser.save_dependencies(depfile, targets)
    io.open(depfile, "w"):write(("%s: %s\n"):format(
        table.concat(targets, " "),
        table.concat(get_deps(), " ")
    ))
end

return parser
