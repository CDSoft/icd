# Interface Control Document generator

`icd` (Interface Control Document) parses a Lua configuration file
and produces source code in various languages.

Note: `icd` is a fork of [lcc](https://gitlab.com/CDSoft/lcc). It adds immutability for a better modularity and reusability.

# Compilation

`icd` requires [LuaX](https://github.com/CDSoft/luax) and [Ninja](https://ninja-build.org):

``` sh
$ git clone https://github.com/CDSoft/luax
$ ninja -C luax install
```

Once LuaX is installed, `icd` can be compiled and installed with ninja:

``` sh
$ git clone https://gitlab.com/CDSoft/icd
$ ninja -C icd install
```

`icd` and `icd.lua` are installed in `$HOME/.local/bin` by default.
The installation directory can be changed with the `PREFIX` environment variable:

``` sh
$ PREFIX="/opt/icd" ninja -C icd install # install icd in /opt/icd/bin/
```

`icd` is a single autonomous executable containing the LuaX interpreter.

`icd.lua` is a Lua script containing the LuaX libraries implemented in Lua.
It requires a Lua 5.4 interpreter.

# Usage

``` sh
$ icd cfg.lua -o output [-n namespace] -backend_1 ... -backend_n
```

- executes `cfg.lua`
- uses backends `backend_1`, ..., `backend_n` to convert the Lua value produced by the Lua script,
- the (optional) `namespace` is prepended to all variable names by the backends,
- the actual output name is determined by replacing the extension of `output` by the backend extension.

``` sh
$ icd.lua cfg.lua -o output.ext [-n namespace]
```

- does the same as above but the backend is determined by the extension of `output.ext`.

| Options               | Description                                               |
|-----------------------|-----------------------------------------------------------|
| `-h`                  | help                                                      |
| `-o output`           | output name                                               |
| `-n namespace`        | use namespace as the toplevel name in the generated code  |
| `-M file`             | save dependencies in file                                 |
| `-I dir`              | add a directory to the import search directory list       |
| `--cpp-const`         | generate cpp `#define` constants (C backend only)         |

# Configuration script environment

The configuration script is executed in the global environment (`_G`)
and shall not produce any side effect.
This environment only contains standard Lua functions and modules
since the configuration is a pure Lua script that can be executed
in any Lua environment (not only by `icd`).

# Code generation customization

## C types

The `__ctype` attribute associates a C type to a Lua value (used by the C backend only).
`__ctype` is a string defining the name of the C type.

## Customized scalar types

The `__custom` attribute defines a customized scalar type.
The type definition is a table `{backend={t="type pattern", v="value pattern"}}`
where:

- `backend` is the backend targeted by the custom type
- `t` is the type pattern (`%s` is replaced by the type name)
- `v` is the value pattern (`%s` is replaced by the value, the default pattern is `%s`)

E.g.:

``` lua
    local my_type = { c={t="type %s", v="(type)%s"} }
    my_param = {__custom=my_type, value}
    -- the C type of my_param will be `type my_param`
    -- the C value of my_param will be `my_param = (type)value`
```

## Generated code prelude

The `__prelude` attribute defines arbitrary text to be added to the generated code.
`__prelude` is a table. Each key represents a backend and values are the texts added to the associated backend.

E.g.:

``` lua
    local prelude = {
        c = [[
            #include "file.h"
        ]],
    }
    ...
    return {
        __prelude = prelude,
        ...
    }
```

# Type inference

## Scalar types

| Lua type              | Abstract type (field `__type` of the annotated values)    |
|-----------------------|-----------------------------------------------------------|
| `boolean`             | `{kind="bool"}`                                           |
| `number` (integer)    | `{kind="uint" or "int", size ∈ [8, 16, 32, 64]}`          |
| `number` (float)      | `{kind="double"}`                                         |
| `string`              | `{kind="str", size=(length of the string)}`               |

## Custom types

Custom types are `{kind="custom", definitions={backend={t="type pattern", v="value pattern"}}}`.

Custom types are not subject to type inference. The type is fully defined by the user.

## Structures

Structures are Lua tables that contain scalars, structures and arrays.
Each field has its own type.

Hybrid Lua tables are not allowed.

Structures types are `{kind="struct", fields={fieldname=fieldtype}}`.

## Arrays

Arrays are Lua arrays that contain scalars, structures and arrays.
All items have the same type.

The types of items are enlarged (size of integers, size of strings, fields of structures, ...)
so that all items have the same type.

Hybrid Lua tables are not allowed.

Arrays types are `{kind="array", size=(number of items), itemtype=(type of items), dim=(dimension number)}`.

The dimension number is user for multiple dimension arrays.

# Backends

## Asymptote: `-asy`

The Asymptote backend produces `output.asy`. It contains Asymptote definitions.

## C: `-c`

The C backend produces `output.h` and `output.c` files:

- `output.h` contains scalar parameters as preprocessor constants
- `output.c` contains scalar and structured parameters as C declarations (types are in `output.h`)

The prelude is added at the beginning of `output.h`.

## Haskell: `-hs`

The Haskell backend produces `output.hs`. It contains Haskell definitions.

## reStructuredText: `-rst`

The reStructuredText backend produces `output.rst`. It contains scalar parameters.
`output.sh` is intended to be sourced by Sphinx as a document prelude.

## Shell: `-sh`

The Shell backend produces `output.sh`. It contains scalar parameters.
`output.sh` is intended to be sourced.

# Examples and tests

The `tests` directory contains Lua configuration test scripts.
`ninja` executes these tests and compares the script outputs to the expected outputs.

The syntax of output files are also checked by several tools:

| Language          | Checkers                          |
|-------------------|-----------------------------------|
| Asymptote         | `asy`                             |
| C                 | `clang-tidy`, `clang`, `gcc`      |
| Haskell           | `ghc`                             |
| reStructuredText  | `pandoc`                          |
| Shell             | `shellcheck`, `bash`, `zsh`       |
| YAML              | `python`, `yamllint`              |
