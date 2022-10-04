local utils = {}

local lua_pairs = pairs

-- like pairs but keys are sorted
function utils.pairs(t)
    local keys = {}
    for k, _ in lua_pairs(t) do table.insert(keys, k) end
    table.sort(keys,
        function(a, b)
            local ta = type(a)
            local tb = type(b)
            return (ta == tb and a < b) or (ta < tb)
        end
    )
    local i = 0
    return function()
        i = i+1
        local k = keys[i]
        local v = t[k]
        return k, v
    end
end

-- format a value (scalar or table), for debug purpose
function utils.dump(x, l)
    l = l or ""
    local l2 = l .. "    "
    local s
    if type(x) == "boolean" then
        s = tostring(x)
    elseif type(x) == "number" then
        s = tostring(x)
    elseif type(x) == "string" then
        s = '"' .. tostring(x) .. '"'
    elseif type(x) == "table" then
        s = "{\n"
        for i, xi in ipairs(x) do
            s = s .. l2 .. "["..i.."] = " .. utils.dump(xi, l2) .. ",\n"
        end
        for k, xk in utils.pairs(x) do
            if type(k) ~= "number" then
                s = s .. l2 .. k .. " = " .. utils.dump(xk, l2) .. ",\n"
            end
        end
        s = s .. l .. "}"
    else
        s = tostring(x)
    end
    return s
end

function utils.concat(t1, t2)
    local t = {}
    for i = 1, #t1 do table.insert(t, t1[i]) end
    for i = 1, #t2 do table.insert(t, t2[i]) end
    return t
end

function utils.append(t, x)
    return utils.concat(t, {x})
end

-- split a name into words
local function split_name(...)
    local words = {}
    local function add_word(name)
        -- an upper case letter starts a new word
        name = tostring(name):gsub("([^%u])(%u)", "%1_%2")
        -- split words
        for w in name:gmatch"%w+" do table.insert(words, w) end
    end
    local function add_words(name)
        for i = 1, #name do add_word(name[i]) end
    end
    for i = 1, select("#", ...) do
        local name = select(i, ...)
        if type(name) == "table" then add_words(name)
        elseif type(name) == "string" then add_word(name)
        end
    end
    return words
end

function utils.lower_snake_case(...)
    local words = split_name(...)
    for i = 1, #words do words[i] = words[i]:lower() end
    return table.concat(words, "_")
end

function utils.upper_snake_case(...)
    local words = split_name(...)
    for i = 1, #words do words[i] = words[i]:upper() end
    return table.concat(words, "_")
end

function utils.lower_camel_case(...)
    local words = split_name(...)
    if #words > 0 then words[1] = words[1]:lower() end
    for i = 2, #words do words[i] = words[i]:lower():gsub("^%l", string.upper) end
    return table.concat(words)
end

function utils.upper_camel_case(...)
    local words = split_name(...)
    for i = 1, #words do words[i] = words[i]:lower():gsub("^%l", string.upper) end
    return table.concat(words)
end

function utils.dotted_lower_snake_case(...)
    local words = split_name(...)
    for i = 1, #words do words[i] = words[i]:lower() end
    return table.concat(words, ".")
end

function utils.dotted_upper_snake_case(...)
    local words = split_name(...)
    for i = 1, #words do words[i] = words[i]:upper() end
    return table.concat(words, ".")
end

function utils.basename(path)
    return path:gsub(".*/", "")
end

function utils.dirname(path)
    return path:gsub("/[^/]*$", "")
end

function utils.file_exists(path)
    local f = io.open(path, "r")
    if f then
        local exists = io.type(f) == "file"
        if f then f:close() end
        return exists
    end
end

local function tb_level()
    local utils_source = debug.getinfo(1, "S").source
    local level = 0
    repeat
        level = level + 1
        local info = debug.getinfo(level, "S")
        if not info then return end
    until info.source ~= utils_source and info.source:match "^@"
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

local function deep_copy(t)
    if type(t) ~= "table" then return t end
    local t2 = {}
    for k, v in pairs(t) do
        t2[k] = deep_copy(v)
    end
    return t2
end

local function check_name_uniqueness(table_name, t)
    if type(t) ~= "table" then return end
    local simplified_names = {}
    for k, _ in pairs(t) do
        if type(k) == "string" then
            local simplified_name = k:gsub("_", ""):lower()
            simplified_names[simplified_name] = simplified_names[simplified_name] or {}
            table.insert(simplified_names[simplified_name], k)
        end
    end
    for _, actual_names in pairs(simplified_names) do
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
    modules[name] = modules[name] or deep_copy(t)
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
        for k, v1 in pairs(t1) do
            local v2 = rawget(t2, k)
            deep_compare(path(name, k), v1, v2)
        end
        for k, v2 in pairs(t2) do
            local v1 = rawget(t1, k)
            deep_compare(path(name, k), v1, v2)
        end
    end
end

local function check_side_effects()
    for name, initial_content in pairs(modules) do
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
