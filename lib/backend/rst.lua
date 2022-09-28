local backend = {}

local parser = require "parser"
local utils = require "utils"

local gen_const, gen_custom

local function gen_rst(ast, namespace)
    local s = table.concat(ast.__prelude and ast.__prelude.rst or {}, "\n")
    parser.leaves(ast, function(path, x, t)
        local name = utils.upper_snake_case(namespace, path)
        local val = gen_const(x, t)
        if val ~= nil then
            s = s .. ".. |" .. name .. "| replace:: " .. val .. "\n\n"
        end
    end)
    return s
end

gen_const = function(x, t)
    if t.kind == "uint" then return tostring(x) end
    if t.kind == "int" then return tostring(x) end
    if t.kind == "bool" then return tostring(x) end
    if t.kind == "double" then return tostring(x) end
    if t.kind == "str" then return tostring(x) end
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
        {"rst", gen_rst(ast, namespace)},
    }
end

return backend
