# TrixiData.jl

[![Docs-stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://trixi-framework.github.io/TrixiData.jl/stable)
[![Docs-dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://trixi-framework.github.io/TrixiData.jl/dev)
[![Build Status](https://github.com/trixi-framework/TrixiData.jl/workflows/CI/badge.svg)](https://github.com/trixi-framework/TrixiData.jl/actions?query=workflow%3ACI)
[![Coveralls](https://coveralls.io/repos/github/trixi-framework/TrixiData.jl/badge.svg)](https://coveralls.io/github/trixi-framework/TrixiData.jl)
[![Codecov](https://codecov.io/gh/trixi-framework/TrixiData.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/trixi-framework/TrixiData.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![License: MIT](https://img.shields.io/badge/License-MIT-success.svg)](https://opensource.org/license/mit/)

[TrixiData.jl](https://github.com/trixi-framework/TrixiData.jl)
distributes data files - meshes for now - used by
packages of the [Trixi Framework](https://github.com/trixi-framework),
in particular in tests, examples, and documentation.

The data are shipped as
[lazy Julia artifacts](https://pkgdocs.julialang.org/v1/artifacts/): nothing is
downloaded when TrixiData.jl is installed. Instead, a data set is downloaded the
first time it is requested and is cached in the Julia depot afterwards, so that
it is downloaded only once per machine - even if several packages use it.


## Usage

Every data set is made available by a function returning the path to the
corresponding file on disk:

```julia
julia> using TrixiData

julia> mesh_file = mesh_tandem_spheres_hex_p2()
"/home/user/.julia/artifacts/0123456789abcdef0123456789abcdef01234567/TandemSpheresHexMesh1P2_fixed.inp"
```

The file lives in the read-only artifact store of the Julia depot. If you need
to modify it, copy it to a writable location first.


## Licenses

The *source code* of TrixiData.jl is licensed under the MIT license
(see [LICENSE.md](LICENSE.md)).

The *data files* distributed via TrixiData.jl are **not** covered by that
license. Each data set keeps the license of its original source. The origin
(including a DOI, if available) and the license of a data set are documented in
the docstring of the function providing access to it. Please check the docstring
and cite the original source when you use a data set.


## Authors and citation

TrixiData.jl is maintained by the
[authors of Trixi.jl](https://github.com/trixi-framework/Trixi.jl/blob/main/AUTHORS.md).
The data files have their own authors. If you use a data set in your own
research, please cite the original source given in the docstring of the
corresponding access function.
