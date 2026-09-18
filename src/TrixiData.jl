module TrixiData

using Artifacts: @artifact_str
# `LazyArtifacts` is not used explicitly, but it must be loaded in this module
# so that `@artifact_str` is allowed to download lazy artifacts on demand, see
# https://pkgdocs.julialang.org/v1/artifacts/#Using-Artifacts
using LazyArtifacts: LazyArtifacts

export mesh_gingerbread_man
export mesh_tandem_spheres_hex_p2

"""
    mesh_gingerbread_man()

Return the path to a two-dimensional mesh of a gingerbread man. It is the
example `GingerbreadMan` of the mesh generator
[HOHQMesh](https://github.com/trixi-framework/HOHQMesh) and is mostly used to
demonstrate and test curved unstructured meshes: the outer boundary `Body` is a
spline, the inner boundaries `Button1`, `Button2`, `Eye1`, `Eye2`, `Smile`, and
`Bowtie` are given by parametric equations.

The mesh is given in HOHQMesh's ISM-V2 format (`.mesh`) and consists of 1,067
nodes, 1,973 edges, and 903 curved quadrilateral elements with boundary curves
of polynomial degree six. Hence, the mesh can be used with
[Trixi.jl](https://github.com/trixi-framework/Trixi.jl) as

```jldoctest
julia> using Trixi, TrixiData

julia> mesh = UnstructuredMesh2D(mesh_gingerbread_man());

julia> ndims(mesh)
2

julia> mesh.n_elements
903

julia> sort(unique(mesh.boundary_names))
8-element Vector{Symbol}:
 Symbol("---")
 :Body
 :Bowtie
 :Button1
 :Button2
 :Eye1
 :Eye2
 :Smile
```

The name `---` marks the element sides that are not on a boundary.

The mesh file is provided as a lazy Julia artifact. It is downloaded the first
time this function is called - roughly 110 KB of download, 520 KB once
unpacked - and cached in the Julia depot afterwards. The returned path points
into the read-only artifact store; copy the file elsewhere if you need to
modify it.

The artifact does not only contain the mesh file but also everything needed
to recreate it: the control file it was generated from, a Julia environment,
and a script that regenerates the mesh and verifies it against the distributed
file. These files live next to the mesh file, so they can be found via

```jldoctest
julia> using TrixiData

julia> sort(readdir(dirname(mesh_gingerbread_man())))
7-element Vector{String}:
 "LICENSE.md"
 "Manifest.toml"
 "Project.toml"
 "README.md"
 "create_mesh.jl"
 "mesh_gingerbread_man.control"
 "mesh_gingerbread_man.mesh"
```

`README.md` documents how the mesh is recreated and how far a regenerated mesh
is from the distributed one.

# Source and license

The mesh file `mesh_gingerbread_man.mesh` is redistributed unmodified from

> Andrew R. Winters (2021).
> Gingerbread man mesh.
> [Gist](https://gist.github.com/andrewwinters5000/2c6440b5f8a57db131061ad7aa78ee2b)

It is the output of HOHQMesh applied to the control file of the example
`GingerbreadMan` shipped with
[HOHQMesh.jl](https://github.com/trixi-framework/HOHQMesh.jl). Both the mesh
generator and that control file are licensed under the MIT license (Copyright
(c) 2010-present David A. Kopriva and other contributors); a copy of the license
is distributed with the mesh as `LICENSE.md`. If you use this mesh, please cite

> David A. Kopriva, Andrew R. Winters, Michael Schlottke-Lakemper,
> Joseph A. Schoonover, Hendrik Ranocha (2024).
> HOHQMesh: An All Quadrilateral/Hexahedral Unstructured Mesh Generator for High
> Order Elements.
> Journal of Open Source Software 9(104), 7476.
> [DOI: 10.21105/joss.07476](https://doi.org/10.21105/joss.07476)
"""
function mesh_gingerbread_man()
    return joinpath(artifact"mesh_gingerbread_man", "mesh_gingerbread_man.mesh")
end

"""
    mesh_tandem_spheres_hex_p2()

Return the path to a mesh file of the tandem spheres configuration: two spheres
of diameter `D = 1` placed one behind the other in a free stream. This is the
geometry of test case CS1 "Tandem Spheres" (Re = 3900) of the 5th International
Workshop on High-Order CFD Methods, see
<https://how5.cenaero.be/content/cs1-tandem-spheres-re3900>.

The mesh is given in Abaqus format (`.inp`) and consists of 256,483 nodes and
31,616 curved hexahedral elements of polynomial degree two (27-node elements of
Abaqus type `C3D27`). The node sets and element sets `FrontSphere`,
`BackSphere`, and `FarField` mark the boundaries, while `Fluid` marks the
volume. Hence, the mesh can be used with
[Trixi.jl](https://github.com/trixi-framework/Trixi.jl) as

```jldoctest
julia> using Trixi, TrixiData

julia> mesh = P4estMesh{3}(mesh_tandem_spheres_hex_p2();
                           boundary_symbols = [:FrontSphere, :BackSphere, :FarField]);

julia> ndims(mesh)
3

julia> Trixi.ncells(mesh)
31616
```

The mesh file is provided as a lazy Julia artifact. It is downloaded the first
time this function is called - roughly 9 MB of download, 24 MB once unpacked -
and cached in the Julia depot afterwards. The returned path points into the
read-only artifact store; copy the file elsewhere if you need to modify it.

# Source and license

The mesh file `TandemSpheresHexMesh1P2_fixed.inp` is redistributed unmodified
from

> Daniel Doehring (2026).
> Mesh Tandem Spheres Hexahedra P2 Fixed.
> Zenodo. [DOI: 10.5281/zenodo.18921889](https://doi.org/10.5281/zenodo.18921889)

It is licensed under the Creative Commons Attribution 4.0 International license
([CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)) - in contrast to the
source code of TrixiData.jl, which is licensed under the MIT license. Please
attribute the source above when you use this mesh.

That data set is in turn derived from the Pointwise mesh published for the
workshop case at
<https://acdl.mit.edu/HOW5/CS1_TandemSpheres/pointwise/gmsh/>. Two changes were
applied to the original Gmsh mesh: the block

```
\$PhysicalNames
4
2 2 "BackSphere"
2 3 "FarField"
2 4 "FrontSphere"
3 1 "Fluid"
\$EndPhysicalNames
```

was added to the `.msh` file to name the two spheres, the far field boundary,
and the fluid volume, and the result was converted to the Abaqus `.inp` format
using Gmsh.

Since Julia artifacts must be downloadable as (compressed) tarballs while Zenodo
serves the bare mesh file, TrixiData.jl distributes the unmodified file
repackaged as a `.tar.gz` archive; see `Artifacts.toml`.
"""
function mesh_tandem_spheres_hex_p2()
    return joinpath(artifact"mesh_tandem_spheres_hex_p2",
                    "TandemSpheresHexMesh1P2_fixed.inp")
end

end # module TrixiData
