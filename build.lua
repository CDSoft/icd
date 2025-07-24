section [[
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

local F = require "F"
local sys = require "sys"

version "1.0"

help.name "LDC"
help.description "Lua Data Compiler"

clean "$builddir"

local clang_tidy = {
    "clang-tidy",
    F{
        "--checks=*",
        "-llvm-header-guard",
        "-llvmlibc-restrict-system-libc-headers",
        "-altera-struct-pack-align",
        "-readability-identifier-length",
        "-modernize-macro-to-enum",
        "-misc-include-cleaner",
    }:str",",
    "-warnings-as-errors=*",
    "-quiet",
}

local shellcheck = {
    "shellcheck",
}

local sources = {
    ls "src/**.lua",
    file "$builddir/ldc-version" { vars.version },
}

build.luax.add_global "flags" "-q"

local binaries = {
    build.luax.native "$builddir/ldc" { sources },
    build.luax.lua "$builddir/ldc.lua" { sources },
}

default(binaries)
install "bin" { binaries }

phony "release" {
    build.tar "$builddir/release/${version}/ldc-${version}-lua.tar.gz" {
        base = "$builddir/release/.build",
        name = "ldc-${version}-lua",
        build.luax.lua("$builddir/release/.build/ldc-${version}-lua/bin/ldc.lua") { sources },
    },
    require "targets" : map(function(target)
        return build.tar("$builddir/release/${version}/ldc-${version}-"..target.name..".tar.gz") {
            base = "$builddir/release/.build",
            name = "ldc-${version}-"..target.name,
            build.luax[target.name]("$builddir/release/.build/ldc-${version}-"..target.name/"bin/ldc") { sources },
        }
    end),
}

rule "ldc" {
    command = "$ldc $in -o $out -M $depfile $args",
    depfile = "$out.d",
    implicit_in = { "$ldc" },
}

rule "check_c" {
    command = {
        "gcc -fsyntax-only $in",
        "&& clang -fsyntax-only $in",
        "&& clang -c $in -o $out.o &&", clang_tidy, "$in", "--", "$in",
        "&& touch $out",
    },
}

rule "check_sh" {
    command = {
        shellcheck, "$in",
        "&& bash -c \". $in\"",
        "&& zsh -c \". $in\"",
        "&& touch $out",
    },
}

rule "check_rst" {
    command = {
        "test \"`pandoc $in -t native`\" = \"[]\"",
        "&& touch $out",
    },
}

rule "check_hs" {
    command = {
        "mkdir -p $out.tmp;",
        "ghc -Wall -Werror -tmpdir $out.tmp -dumpdir $out.tmp -hidir $out.tmp -odir $out.tmp -outputdir $out.tmp $in",
        "&& touch $out",
    },
}

rule "check_asy" {
    command = {
        "asy $in",
        "&& touch $out",
    },
}

rule "check_yaml" {
    command = {
        "python -c 'import yaml, sys; print(yaml.safe_load(sys.stdin))' < $in > /dev/null",
        "&& yamllint $in",
        "&& touch $out",
    },
}

rule "diff" {
    command = {
        --"cp -fv $in;", -- uncomment to update all reference files
        "diff $in > $out || (cat $out && false)",
    },
}

ls "tests/*.lua"
: foreach(function(test)

    F{"lua", "luax"} : foreach(function(interpreter)

        local out = "$builddir"/"test-"..interpreter/test:basename():splitext()
        local name = out:basename()

        default {

            build { out..".c" } { "ldc", test,
                args = { "--cpp-const" },
                ldc = "$builddir/ldc"..(interpreter=="lua" and ".lua" or sys.exe),
                implicit_out = {
                    out..".h",
                    out..".c.d",
                },
                validations = {
                    build(out..".c.ok") { "check_c", out..".c" },
                    --build(out..".h.ok") { "check_c", out..".h" },
                    build(out..".c.diff.ok")   { "diff", out..".c",   "tests"/name..".c" },
                    build(out..".c.d.diff.ok") { "diff", out..".c.d", "tests"/name..".c.d-"..interpreter },
                    build(out..".h.diff.ok")   { "diff", out..".h",   "tests"/name..".h" },
                },
            },
            F"sh rst hs asy yaml":words():map(function(ext)
                return build { out.."."..ext } { "ldc", test,
                    ldc = "$builddir/ldc"..(interpreter=="lua" and ".lua" or sys.exe),
                    implicit_out = {
                        out.."."..ext..".d",
                    },
                    validations = {
                        build(out.."."..ext..".ok") { "check_"..ext, out.."."..ext },
                        build(out.."."..ext..".diff.ok")   { "diff", out.."."..ext,       "tests"/name.."."..ext },
                        build(out.."."..ext..".d.diff.ok") { "diff", out.."."..ext..".d", "tests"/name.."."..ext..".d-"..interpreter },
                    },
                }
            end),

        }

    end)
end)
