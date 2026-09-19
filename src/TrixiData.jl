module TrixiData

using Artifacts: @artifact_str
# `LazyArtifacts` is not used explicitly, but it must be loaded in this module
# so that `@artifact_str` is allowed to download lazy artifacts on demand, see
# https://pkgdocs.julialang.org/v1/artifacts/#Using-Artifacts
using LazyArtifacts: LazyArtifacts

# The data sets are listed in alphabetical order, here as well as in
# `Artifacts.toml` and in the tests.

export mesh_onera_m6_wing
export mesh_tandem_spheres_hex_p2

@doc raw"""
    mesh_onera_m6_wing()

Return the path to a mesh file of the ONERA M6 wing, a swept, semi-span wing
without twist that is one of the classical validation cases for transonic
external aerodynamics. The geometry follows the experiments of Schmitt and
Charpin [1] in the form used for CFD simulations [2], i.e., with the finite
trailing-edge thickness of the ONERA D airfoil section closed to zero. All
lengths are rescaled such that the nominal span of the modeled semi-wing
(b = 1.1963 m in [1, 2]) is one; around the tip, the wing surface extends
slightly beyond that, up to z ≈ 1.0168. The surrounding domain extends from
-6.373 to 7.411 in `x`, from -6.375 to 6.375 in `y`, and from 0 to 7.373 in
`z`, where the plane `z = 0` is the symmetry plane of the wing.

The mesh is given in Abaqus format (`.inp`) and consists of 306,503 nodes and
294,838 straight-sided hexahedral elements (8-node elements of Abaqus type
`C3D8`) forming the element set `Volume1`. The node sets `Symmetry`, `FarField`,
`BottomWing`, and `TopWing` mark the symmetry plane, the outer boundary, and the
lower and upper wing surface, respectively. The airfoil sections are symmetric
and the trailing edge is closed, so `BottomWing` and `TopWing` share the 139
nodes at which the lower and the upper surface meet. Hence, the mesh can be
used with
[Trixi.jl](https://github.com/trixi-framework/Trixi.jl) as

```jldoctest
julia> using Trixi, TrixiData

julia> mesh = P4estMesh{3}(mesh_onera_m6_wing();
                           boundary_symbols = [:Symmetry, :FarField,
                                               :BottomWing, :TopWing]);

julia> ndims(mesh)
3

julia> Trixi.ncells(mesh)
294838
```

The mesh file is provided as a lazy Julia artifact. It is downloaded the first
time this function is called - roughly 10 MB of download, 33 MB once unpacked -
and cached in the Julia depot afterwards. The returned path points into the
read-only artifact store; copy the file elsewhere if you need to modify it. Next
to the mesh file, the artifact directory contains the license of the mesh
(`LICENSE`) and a `README.md` repeating the information given below.

# Origin

For the geometry of [1], a purely hexahedral mesh split into four blocks is
available from the NPARC Alliance Validation Archive of NASA [2]. The HiSA
team [3] converted these four blocks into a single Gmsh file, available at
<https://gitlab.com/hisa/hisa/-/blob/master/examples/oneraM6/mesh/p3dMesh/m6wing.msh>
(see also <https://hisa.gitlab.io/archive/nparc/oneraM6/notes/oneraM6.html>),
which still contains the nodes duplicated at the block interfaces.

Daniel Doehring sanitized the result to make it usable with high-order
discontinuous Galerkin methods, as described in Section 5.4 of [5]: duplicated
nodes originating from the different blocks were deleted and the node labels
were replaced accordingly, 72 hexahedra degenerated into prisms were merged
pairwise into single hexahedra, and two corrupted elements on the wing surface
were deleted and the resulting hole was remeshed locally using Gmsh [4]. The
resulting mesh is published as
`5_Applications/5_4_ONERA_M6/ONERA_M6_sanitized.inp` in the reproducibility
repository [6] of the article [5].

# How to cite

When you use this mesh, please cite all the sources that it builds upon:

1. V. Schmitt, F. Charpin (1979).
   Pressure distributions on the ONERA-M6 wing at transonic Mach numbers.
   Chapter B1 of "Experimental Data Base for Computer Program Assessment.
   Report of the Fluid Dynamics Panel Working Group 04",
   Advisory Report AR-138, AGARD, May 1979.
2. J. W. Slater (2002).
   ONERA M6 Wing: Study #1.
   NPARC Alliance Validation Archive, NASA John H. Glenn Research Center.
   Example study demonstrating the computation of a 3D transonic wing flow.
   <https://www.grc.nasa.gov/WWW/wind/valid/m6wing/m6wing01/m6wing01.html>
3. J. A. Heyns, O. F. Oxtoby, A. Steenkamp (2014).
   Modelling high-speed flow using a matrix-free coupled solver.
   9th OpenFOAM Workshop, 23-26 June 2014, Zagreb, Croatia.
4. C. Geuzaine, J.-F. Remacle (2009).
   Gmsh: A 3-D finite element mesh generator with built-in pre- and
   post-processing facilities.
   International Journal for Numerical Methods in Engineering 79, pp. 1309-1331.
   [DOI: 10.1002/nme.2579](https://doi.org/10.1002/nme.2579)
5. D. Doehring, H. Ranocha, M. Torrilhon (2025).
   Paired Explicit Relaxation Runge-Kutta Methods: Entropy-Conservative and
   Entropy-Stable High-Order Optimized Multirate Time Integration.
   [DOI: 10.48550/arXiv.2507.04991](https://doi.org/10.48550/arXiv.2507.04991)
6. D. Doehring, H. Ranocha, M. Torrilhon (2025).
   Reproducibility repository for "Paired Explicit Relaxation Runge-Kutta
   Methods: Entropy-Conservative and Entropy-Stable High-Order Optimized
   Multirate Time Integration".
   [DOI: 10.5281/zenodo.15601890](https://doi.org/10.5281/zenodo.15601890)

The corresponding BibLaTeX entries are

```bibtex
@techreport{schmitt1979pressure,
  title={Pressure distributions on the {ONERA}-{M6} wing at transonic
         {M}ach numbers},
  author={Schmitt, V. and Charpin, F.},
  institution={AGARD},
  type={Advisory Report},
  number={AR-138},
  year={1979},
  month={05},
  note={Chapter B1 of "Experimental Data Base for Computer Program
        Assessment. Report of the Fluid Dynamics Panel Working Group 04"}
}

@misc{slater2002onera,
  title={{ONERA} {M6} Wing: Study \#1},
  author={Slater, John W.},
  year={2002},
  month={08},
  howpublished={\url{https://www.grc.nasa.gov/WWW/wind/valid/m6wing/m6wing01/m6wing01.html}},
  note={NPARC Alliance Validation Archive,
        NASA John H. Glenn Research Center.
        Example study demonstrating the computation of a
        3{D} transonic wing flow}
}

@inproceedings{heyns2014modelling,
  title={Modelling high-speed flow using a matrix-free coupled solver},
  author={Heyns, Johan A. and Oxtoby, Oliver F. and Steenkamp, Adriaan},
  booktitle={9th OpenFOAM Workshop},
  address={Zagreb, Croatia},
  year={2014},
  month={06},
  note={23--26 June 2014}
}

@article{geuzaine2009gmsh,
  title={{G}msh: A 3-{D} finite element mesh generator with built-in
         pre- and post-processing facilities},
  author={Geuzaine, Christophe and Remacle, Jean-François},
  journal={International Journal for Numerical Methods in Engineering},
  volume={79},
  number={11},
  pages={1309--1331},
  year={2009},
  doi={10.1002/nme.2579}
}

@online{doehring2025paired,
  title={Paired Explicit Relaxation {R}unge-{K}utta Methods:
         Entropy-Conservative and Entropy-Stable High-Order Optimized
         Multirate Time Integration},
  author={Doehring, Daniel and Ranocha, Hendrik and Torrilhon, Manuel},
  year={2025},
  month={07},
  eprint={2507.04991},
  eprinttype={arxiv},
  eprintclass={math.NA},
  doi={10.48550/arXiv.2507.04991}
}

@misc{doehring2025pairedRepro,
  title={Reproducibility repository for
         "{P}aired Explicit Relaxation {R}unge-{K}utta Methods:
         Entropy-Conservative and Entropy-Stable High-Order Optimized
         Multirate Time Integration"},
  author={Doehring, Daniel and Ranocha, Hendrik and Torrilhon, Manuel},
  year={2025},
  howpublished={\url{https://github.com/DanielDoehring/paper-2025-perrk}},
  doi={10.5281/zenodo.15601890}
}
```

# Source and license

The mesh file `ONERA_M6_sanitized.inp` is redistributed unmodified from the
reproducibility repository [6], <https://github.com/DanielDoehring/paper-2025-perrk>
(commit `2aa58313108d33887b1e87ced393cd32fd4731d5`), where it is licensed under
the MIT license - like the source code of TrixiData.jl, but with a different
copyright holder. The license text is included in the artifact as `LICENSE`.

Since Julia artifacts must be downloadable as (compressed) tarballs while the
source repository serves bare files, TrixiData.jl distributes the mesh file
repackaged as a `.tar.gz` archive, together with the license and a `README.md`
written by the authors of TrixiData.jl; see `Artifacts.toml`.
"""
function mesh_onera_m6_wing()
    return joinpath(artifact"mesh_onera_m6_wing",
                    "ONERA_M6_sanitized.inp")
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
