local F = require "F"

var "builddir" ".build"

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
    }:str",",
    "-warnings-as-errors=*",
    "-quiet",
}

local shellcheck = {
    "shellcheck",
}

local sources = ls "src/**.lua"

default {
    build "$builddir/icd"     { sources, command = "luax -q -o $out $in" },
    build "$builddir/icd.lua" { sources, command = "luax -q -t lua -o $out $in" },
}

install "bin" "$builddir/icd"
install "bin" "$builddir/icd.lua"

rule "icd" {
    command = {
        "$icd $in -o $out",
        "-M $depfile",
        "$args",
    },
    depfile = "$out.d",
    implicit_in = {
        "$icd",
    },
}

rule "check_c" {
    command = {
        "gcc -fsyntax-only $in",
        "&& clang -fsyntax-only $in",
        "&& clang -c $in -o $out.o && ", clang_tidy, "$in", "--", "$in",
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

            build { out..".c" } { "icd", test,
                args = { "--cpp-const" },
                icd = "$builddir/icd"..(interpreter=="lua" and ".lua" or ""),
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
                return build { out.."."..ext } { "icd", test,
                    icd = "$builddir/icd"..(interpreter=="lua" and ".lua" or ""),
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
