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

local protected_environment = {
    __index = function(_, name)
        error(name..": undefined identifier")
    end,
    __newindex = function(_, name)
        error(name..": can not create new variables")
    end,
}

function utils.protect(env)
    return setmetatable(env, protected_environment)
end

return utils
