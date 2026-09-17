# Development

This page describes how to add a new data set to TrixiData.jl. It is written for
contributors; if you only want to *use* a data set, see the
[API reference](@ref "API reference").


## How data sets are distributed

Every data set of TrixiData.jl is a
[lazy Julia artifact](https://pkgdocs.julialang.org/v1/artifacts/). Lazy means
that nothing is downloaded when TrixiData.jl is installed. Instead, the artifact
is downloaded the first time it is requested via `@artifact_str` and is then
cached in the artifact store of the Julia depot (usually
`~/.julia/artifacts/<git-tree-sha1>`), so that it is downloaded only once per
machine, no matter how many packages use it.

Julia can only download artifacts as **(compressed) tarballs**: `Pkg`
decompresses the downloaded file and feeds the result into `Tar.extract`, so
anything that is not a tarball fails to unpack. Data files published
elsewhere - for example a bare mesh file on Zenodo - therefore have to be
repackaged as a `.tar.gz` archive, which TrixiData.jl attaches to one of its own
GitHub releases. The original publication stays the citable source; the release
asset is only a redistribution in a format that Julia can consume.

An artifact is identified by two hashes:

- `git-tree-sha1` identifies the *unpacked content*. `Pkg` recomputes it after
  unpacking and refuses the download if it does not match, so it also determines
  the directory name in the artifact store.
- `sha256` identifies the *tarball* that is downloaded. It protects the
  download itself.


## Adding a new data set

The steps below use the existing [`mesh_tandem_spheres_hex_p2`](@ref) as a
running example. Replace `mesh_tandem_spheres_hex_p2` by the name of your new
data set throughout; by convention, the artifact name and the name of the
accessor function are identical.

### 1. Check the source and the license

Only add data that may be redistributed. Record

- the original publication, ideally with a DOI,
- its license,
- and every modification that was applied to the original data.

All of this goes into the docstring of the accessor function (step 5). Data
files keep the license of their source, which is usually *not* the MIT license
of the TrixiData.jl source code.

### 2. Create a reproducible tarball

Use `Tar.create` from [Tar.jl](https://github.com/JuliaIO/Tar.jl) together with
`gzip -9 -n`. `Tar.create` normalizes permissions, timestamps, and ownership,
and `gzip -n` omits the file name and timestamp from the archive header. The
resulting `.tar.gz` is therefore bit-for-bit reproducible: anyone can recreate
the exact file that the `sha256` below refers to.

```julia
using Downloads: Downloads
using Tar: Tar
using SHA: sha256

# The file(s) as published by the original source
url = "https://zenodo.org/records/18921889/files/TandemSpheresHexMesh1P2_fixed.inp?download=1"
filename = "TandemSpheresHexMesh1P2_fixed.inp"

# Everything inside `tree` becomes the content of the artifact
dir = mktempdir()
tree = mkpath(joinpath(dir, "tree"))
Downloads.download(url, joinpath(tree, filename))

# Pack it; `Tar.tree_hash` is the `git-tree-sha1` of the artifact
tarball = joinpath(dir, "TandemSpheresHexMesh1P2_fixed.tar")
Tar.create(tree, tarball)
println("git-tree-sha1 = ", Tar.tree_hash(tarball))

run(`gzip -9 -n $tarball`)
println("sha256        = ", bytes2hex(open(sha256, tarball * ".gz")))
println("tarball       = ", tarball * ".gz")
```

Keep the two printed hashes; they go into `Artifacts.toml` in step 4.

### 3. Publish the tarball as a GitHub release asset

Attach the `.tar.gz` to a release of TrixiData.jl. Use a tag of the form
`data-<artifact name>` so that data releases are clearly separated from the
version tags `v*` of the package itself:

```shell
gh release create data-mesh_tandem_spheres_hex_p2 \
    --repo trixi-framework/TrixiData.jl \
    --title "Mesh Tandem Spheres Hexahedra P2 Fixed" \
    --notes "Repackaged from https://doi.org/10.5281/zenodo.18921889 (CC BY 4.0)" \
    TandemSpheresHexMesh1P2_fixed.tar.gz
```

Never replace the asset of an existing data release. The `sha256` recorded in
`Artifacts.toml` would no longer match, and every user who already cached the
artifact would keep the old content. If a data set has to change, add a new one
instead, see [Changing or removing a data set](@ref).

### 4. Declare the artifact in `Artifacts.toml`

Add an entry with the two hashes from step 2 and the download URL from step 3.
Setting `lazy = true` is essential - without it, the data would be downloaded
whenever TrixiData.jl is installed.

```toml
[mesh_tandem_spheres_hex_p2]
git-tree-sha1 = "a7db536cdc5eb3c01369302db6e0ed78cd460d3b"
lazy = true

    [[mesh_tandem_spheres_hex_p2.download]]
    sha256 = "451f1410da26d79c70a63c0d8ec22f78a62549eb35e009261f4a6e6bf8763162"
    url = "https://github.com/trixi-framework/TrixiData.jl/releases/download/data-mesh_tandem_spheres_hex_p2/TandemSpheresHexMesh1P2_fixed.tar.gz"
```

Add a comment above the entry that names the original source, its license, and
how the tarball was created, so that the archive can be reproduced from
`Artifacts.toml` alone.

### 5. Add the accessor function

Add a function returning the path to the file in `src/TrixiData.jl` and export
it. Since `@artifact_str` returns the path of the artifact *directory*, join it
with the file name.

```julia
export mesh_tandem_spheres_hex_p2

"""
    mesh_tandem_spheres_hex_p2()

[...] Describe what the data set contains and how it can be used. [...]

# Source and license

[...] Name the original publication including its DOI, the license it is
published under, and all modifications applied to the original data. [...]
"""
function mesh_tandem_spheres_hex_p2()
    return joinpath(artifact"mesh_tandem_spheres_hex_p2",
                    "TandemSpheresHexMesh1P2_fixed.inp")
end
```

The docstring is the only place where users learn where a data set comes from
and under which conditions they may use it, so please be explicit there.

A docstring may contain a doctest that accesses the data set; nothing special is
required for that. `docs/make.jl` installs every artifact declared in
`Artifacts.toml` before `makedocs` runs, so the progress information that `Pkg`
prints while downloading (see [Verifying the download](@ref)) does not become
part of the captured doctest output.

Two properties of the module must be preserved:

- `using LazyArtifacts` has to stay in `src/TrixiData.jl`. `@artifact_str`
  refuses to download a lazy artifact unless the name `LazyArtifacts` is defined
  in the calling module.
- `@artifact_str` with a literal name is resolved while the package is
  precompiled, and `Artifacts.toml` is registered as an include dependency.
  Editing `Artifacts.toml` therefore triggers recompilation automatically.

### 6. Add a test

Add a `@testitem` tagged `:artifacts` in a file `test/test_<name>.jl` that
downloads the data set and checks its content against the checksum of the
*original* file - not of the tarball. This verifies the whole chain from the
original publication to the accessor function.

```julia
@testitem "mesh_tandem_spheres_hex_p2" tags=[:artifacts] begin
    using SHA: sha256

    mesh_file = mesh_tandem_spheres_hex_p2()

    @test isfile(mesh_file)
    @test basename(mesh_file) == "TandemSpheresHexMesh1P2_fixed.inp"
    @test bytes2hex(open(sha256, mesh_file)) ==
          "2db6b8d583fc139120fd8a2d4c5d2fa4610f74b7f0e7c2372c6cecbe15884d5e"
end
```

To run only the tests that do not need network access, set
`TRIXIDATA_TEST=quality`; `TRIXIDATA_TEST=artifacts` runs only the data set
tests.

### 7. Update `NEWS.md`

Add an entry under `#### Added` of the current
`## Changes in the vX.Y lifecycle` section that names the new function and the
source of the data, including its DOI and license.


## Verifying the download

Julia reuses an artifact that is already present in the depot, so a local test
run does not prove that the URL in `Artifacts.toml` actually works. Force a real
download by pointing `JULIA_DEPOT_PATH` at an empty directory:

```shell
JULIA_DEPOT_PATH=$(mktemp -d) julia --project=. -e 'using TrixiData; @show mesh_tandem_spheres_hex_p2()'
```

Do not append a colon to the path - that would add the default depots back and
the cached artifact would be used again.

Julia always queries the package server before it falls back to the URLs
listed in `Artifacts.toml`. The package server does not host our data, so a
successful download looks like this:

```
 Downloading artifact: mesh_tandem_spheres_hex_p2
     Failure artifact: mesh_tandem_spheres_hex_p2
 Downloading artifact: mesh_tandem_spheres_hex_p2
```

The `Failure` line refers to the package server, not to the release asset.


## Changing or removing a data set

The content returned by an accessor function is part of the public API of
TrixiData.jl. Users pin a version of TrixiData.jl expecting to get exactly the
same bytes, and artifacts are cached indefinitely, so silently exchanging a data
set would make results irreproducible.

- **Correcting a data set** means adding a *new* artifact with a new name and a
  new data release, and deprecating the old accessor function. Both artifacts
  can coexist.
- **Removing** an accessor function or an artifact entry is a breaking change.
  Users can free the disk space of artifacts that are no longer referenced by
  running `Pkg.gc()`.

Both cases require an entry in `NEWS.md` under `#### Deprecated` or
`#### Removed`.
