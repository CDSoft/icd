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

local utils = require "utils"
utils.protect(_G) -- protection against some side effects in _G

local F = require "F"
local fs = require "fs"

local version = require "ldc-version"

-- Command line arguments

local args = (function()
    local parser = require "argparse"()
        : name "LDC"
        : description "Lua Data Compiler"
        : epilog "For more information, see https://codeberg.org/cdsoft/ldc"
    parser : flag "-v"
        : description(('Print LDC version ("%s")'):format(version))
        : action(function() print(version); os.exit() end)
    parser : argument "input"
        : description "input Lua script"
        : args "1"
    parser : option "-o"
        : description "output name"
        : argname "output"
        : target "output"
        : count "1"
    parser : argument "backends"
        : description "backend list"
        : args "*"
        : convert(function(opt) return (require("backend."..opt)) end)
    parser : option "-n"
        : description "namespace"
        : argname "namespace"
        : target "namespace"
        : count "0-1"
    parser : option "-I"
        : description "import directory"
        : argname "import_dir"
        : target "import_dir"
        : count "*"
    parser : flag "--cpp-const"
        : description "generate cpp defined constants (C backend only)"
        : target "cpp_const"
    parser : option "-M"
        : description "dependency file"
        : argname "depfile"
        : target "depfile"
        : count "0-1"
    return parser:parse(arg)
end)()

print "Lua Data Compiler"

F.foreach(args.import_dir, function(path)
    package.path = path.."/?.lua;"..package.path
end)
args.namespace = args.namespace or args.input:gsub("%.lua$", ""):gsub("/", "_")

if #args.backends == 0 then
    local ext = args.output:ext():gsub("^%.", "")
    if ext and #ext > 0 then table.insert(args.backends, (require("backend."..ext))) end
end

print("input:", args.input)

-- Execute the configuration script

local configuration = utils.require(args.input:gsub("%.lua$", ""))

-- Add type annotations for the backends

local parser = require "parser"
local ast = parser.compile(configuration)

-- Run the backends

local outputs = {}
for _, backend in ipairs(args.backends) do
    for _, compiled_code in ipairs(backend.compile(args.output, ast, args.namespace, args)) do
        local ext, code = F.unpack(compiled_code)
        local filename = args.output:splitext().."."..ext
        table.insert(outputs, filename)
        print("output:", filename)
        assert(fs.write(filename, code))
        if filename:match("%.[ch]$") then
            os.execute("clang-format -i -style=Microsoft "..filename)
        end
    end
end

-- Save dependencies

if args.depfile then
    parser.save_dependencies(args.depfile, args.input, outputs)
end
