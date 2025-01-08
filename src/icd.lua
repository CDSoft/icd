#!/usr/bin/env lua

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
http://github.com/CDSoft/icd
]]

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

local utils = require "utils"
utils.protect(_G) -- protection against some side effects in _G

local F = require "F"
local fs = require "fs"

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
            table.insert(backends, (require("backend."..opt)))
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
    if ext and #ext > 0 then table.insert(backends, (require("backend."..ext))) end
end

print("input:", input)

-- Execute the configuration script

local configuration = utils.require(input:gsub("%.lua$", ""))

-- Add type annotations for the backends

local parser = require "parser"
local ast = parser.compile(configuration)

-- Run the backends

local outputs = {}
for _, backend in ipairs(backends) do
    for _, compiled_code in ipairs(backend.compile(output, ast, namespace, params)) do
        local ext, code = F.unpack(compiled_code)
        local filename = output:splitext().."."..ext
        table.insert(outputs, filename)
        print("output:", filename)
        assert(fs.write(filename, code))
        if filename:match("%.[ch]$") then
            os.execute("clang-format -i -style=Microsoft "..filename)
        end
    end
end

-- Save dependencies

if depfile then
    parser.save_dependencies(depfile, input, outputs)
end
