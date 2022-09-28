#!/usr/bin/env lua

print "Interface Control Document generator"

local help = [[
usage:
    icd cfg.lua -o output [-n namespace] [backend list]
        generates output.ext1 ... output.extn for each backend
    icd cfg.lua -o output.ext [-n namespace]
        generates output.ext where ext is a backend

options:
    -h              help
    -o              output name
    -n              namespace
    -M              dependency file
    -I              import directory
    --cpp-const     generate cpp defined constants (C backend only)
]]

local icdpath = arg[0]:gsub("/[^/]*$", "")
local icdlib = icdpath.."/lib"
package.path = icdlib.."/?.lua;"..package.path

-- Command line arguments

local input = nil
local output = nil
local backends = {}
local namespace = nil
local depfile = nil
local params = {
    cpp_const = false,
}

local function add_path(path)
    package.path = path.."/?.lua;"..package.path
end

while #arg > 0 do
    local a = table.remove(arg, 1)
    local opt = a:match "^-(.*)"
    if opt then
        if a == "-h" then
            print(help)
            os.exit()
        elseif a == "-o" then
            assert(#arg > 0, help)
            assert(not output, "duplicate output parameter")
            output = table.remove(arg, 1)
        elseif a == "-n" then
            assert(#arg > 0, help)
            assert(not namespace, "duplicate namespace parameter")
            namespace = table.remove(arg, 1)
        elseif a == "-M" then
            assert(#arg > 0, help)
            assert(not depfile, "duplicate dependency file parameter")
            depfile = table.remove(arg, 1)
        elseif a == "-I" then
            assert(#arg > 0, help)
            local import_dir = table.remove(arg, 1)
            add_path(import_dir)
        elseif a == "--cpp-const" then
            params.cpp_const = true
        else
            table.insert(backends, (require("backend/"..opt)))
        end
    else
        assert(not input, "duplicate input parameter")
        input = a
    end
end

namespace = namespace or input:gsub("%.lua$", ""):gsub("/", "_")

assert(input, "input script not specified")
assert(output, "output not specified")

if #backends == 0 then
    local ext = output:match("%.([^%.]*)$")
    if ext and #ext > 0 then table.insert(backends, require("backend/"..ext)) end
end

print("input:", input)

-- Execute the configuration script

-- TODO : protéger _G contre les modifications (ou au moins la création de nouvelles variables)
-- ou vérifier l'état de _G avant et après exécution du script
local configuration = assert(require(input:gsub("%.lua$", "")))

-- Add type annotations for the backends

local parser = require "parser"
local ast = parser.compile(configuration)

-- Run the backends

local outputs = {}
for _, backend in ipairs(backends) do
    for _, compiled_code in ipairs(backend.compile(output, ast, namespace, params)) do
        local ext = compiled_code[1]
        local code = compiled_code[2]
        local filename = output:gsub("%.[^%.]+$", "").."."..ext
        table.insert(outputs, filename)
        print("output:", filename)
        io.open(filename, "w"):write(code)
    end
end

-- Save dependencies

if depfile then
    parser.save_dependencies(depfile, outputs)
end
