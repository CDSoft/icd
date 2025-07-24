# Lua Data Compiler

`ldc` (Lua Data Compiler) parses a Lua script
and produces source code in various languages.

Note: `ldc` is a fork of [lcc](https://gitlab.com/CDSoft/lcc).
It adds immutability for a better modularity and reusability.

# Pricing

LDC is a free and open source software.
But it has a cost. It takes time to develop, maintain and support.

To help LDC remain free, open source and supported,
users are cordially invited to contribute financially to its development.

| LDC price          | Europe        | United States | Rest of the World |
| ------------------ | ------------- | ------------- | ----------------- |
| Personal usage     | Free donation | Free donation | Free donation     |
| Academic usage     | €10 or more   | $20 or more   | $15 or more       |
| Professional usage | €20 or more   | $40 or more   | $25 or more       |

These prices are per month and per tools (see [`PRICING`](PRICING)).

<a href='https://liberapay.com/LuaX/donate' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://liberapay.com/assets/widgets/donate.svg' border='0' alt='Donate using Liberapay' /></a>
<a href='https://ko-fi.com/K3K11CD108' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi6.png?v=6' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

Feel free to promote LDC!

# Compilation

`ldc` requires [LuaX](https://codeberg.org/cdsoft/luax),
[Bang](https://codeberg.org/cdsoft/bang) and [Ninja](https://ninja-build.org):

``` sh
$ git clone https://codeberg.org/cdsoft/luax
$ cd luax
$ ./bootstrap.sh
$ ninja install
```

Once LuaX is installed, `bang` can be compiled and installed with ninja:

``` sh
$ git clone https://codeberg.org/cdsoft/bang
$ cd bang
$ ./boot.lua
$ ninja install
```

`ldc` can finally be compiled and installed:

``` sh
$ git clone https://codeberg.org/cdsoft/ldc
$ cd ldc
$ bang
$ ninja -C ldc install
```

`ldc` and `ldc.lua` are installed in `$HOME/.local/bin` by default.
The installation directory can be changed with the `PREFIX` environment variable:

``` sh
$ PREFIX="/opt/ldc" ninja -C ldc install # install ldc in /opt/ldc/bin/
```

`ldc` is a single autonomous executable containing the LuaX interpreter.

`ldc.lua` is a Lua script containing the LuaX libraries implemented in Lua.
It requires a Lua 5.4 interpreter.

# Usage

``` sh
$ ldc cfg.lua -o output [-n namespace] -backend_1 ... -backend_n
```

- executes `cfg.lua`
- uses backends `backend_1`, ..., `backend_n` to convert the Lua value produced by the Lua script,
- the (optional) `namespace` is prepended to all variable names by the backends,
- the actual output name is determined by replacing the extension of `output` by the backend extension.

``` sh
$ ldc.lua cfg.lua -o output.ext [-n namespace]
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
in any Lua environment (not only by `ldc`).

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

# License

```
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
```
