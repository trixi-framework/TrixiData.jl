module TrixiData

using Artifacts: @artifact_str
# `LazyArtifacts` is not used explicitly, but it must be loaded in this module
# so that `@artifact_str` is allowed to download lazy artifacts on demand, see
# https://pkgdocs.julialang.org/v1/artifacts/#Using-Artifacts
using LazyArtifacts: LazyArtifacts

# The data sets are listed in alphabetical order, here as well as in
# `Artifacts.toml` and in the tests.

export mesh_nasa_crm_hex_p1
export mesh_onera_m6_wing
export mesh_tandem_spheres_hex_p2

@doc raw"""
    mesh_nasa_crm_hex_p1()

Return the path to a mesh file of the NASA Common Research Model (CRM) [1], a
contemporary transonic transport configuration designed as a common geometry
for CFD validation studies. The mesh discretizes the wing-body variant of the
CRM at full scale with all lengths given in meters; the wing reference chord is
7.005 m. The flow direction is `x`, the wing spans in `y`, and `z` points
upwards, so that the plane `y = 0` is the symmetry plane of the aircraft. The
aircraft surface extends from 2.36 to 65.10 in `x`, from 0 to 29.46 in `y`, and
from 2.31 to 8.72 in `z`. The surrounding domain is the half `y >= 0` of a
bullet-shaped region of radius R = 7005.32 m, i.e., 1000 reference chords: a
hemispherical cap around the origin ahead of the aircraft (`x <= 0`,
`x^2 + y^2 + z^2 = R^2`), continued downstream as a circular cylinder around
the `x` axis (`y^2 + z^2 = R^2`) and closed by the outflow plane `x = R`.

The mesh is given in Abaqus format (`.inp`) and consists of 85,093 nodes and
79,505 straight-sided hexahedral elements (8-node elements of Abaqus type
`C3D8`) forming the element set `Volume0`. The boundaries are discretized by
10,984 additional quadrilateral surface elements (4-node elements of Abaqus
type `CPS4`), grouped into the node sets `FUSELAGE` (the fuselage surface),
`WING` (the blunt trailing edge and the wing tip), `WING_UP` and `WING_LO` (the
upper and lower wing surface), `SYMMETRY` (the symmetry plane), `FARFIELD` (the
hemispherical cap and the cylinder), and `OUTFLOW` (the outflow plane). Since
[Trixi.jl](https://github.com/trixi-framework/Trixi.jl) identifies boundaries
via these node sets, the mesh can be used as

```jldoctest
julia> using Trixi, TrixiData

julia> mesh = P4estMesh{3}(mesh_nasa_crm_hex_p1();
                           boundary_symbols = [:FUSELAGE, :WING,
                                               :WING_UP, :WING_LO,
                                               :SYMMETRY, :FARFIELD, :OUTFLOW]);

julia> ndims(mesh)
3

julia> Trixi.ncells(mesh)
79505
```

This mesh is very coarse for the transonic viscous flow it is usually applied
to; it is used in [4] to demonstrate time integration methods rather than to
resolve the flow accurately.

The seven boundary names listed above are also defined as element sets
(`*ELSET`) in the mesh file. These are inherited unchanged from the original
grid described below and one of them is defective: the element set `FUSELAGE`
lists the volume element 3509 instead of the surface element 81859, which is
the last element of the corresponding block `*ELEMENT, type=CPS4,
ELSET=Surface1`. The node sets (`*NSET`) are not affected, so this does not
influence the usage shown above.

The mesh file is provided as a lazy Julia artifact. It is downloaded the first
time this function is called - roughly 3 MB of download, 10 MB once unpacked -
and cached in the Julia depot afterwards. The returned path points into the
artifact store; the mesh file itself is read-only, so copy it elsewhere if you
need to modify it. Note that some tools write derived files next to the mesh
file: the `P4estMesh` constructor of Trixi.jl, for example, creates
`..._preproc.inp` and `..._p4est_ready.inp` in the artifact directory. This
succeeds in a standard depot, but it modifies an artifact that is meant to be
immutable, so that `Pkg.Artifacts.verify_artifact` reports a mismatch
afterwards; with a read-only depot it fails. Copy the mesh file to a writable
directory first to avoid this. Next to the mesh file, the artifact directory
contains the license of the mesh (`LICENSE`) and a `README.md` repeating the
information given below.

# Origin

For the third International Workshop on High-Order CFD Methods [2] held in
2015, Marco Ceze (University of Michigan) provided a hexahedral mesh of the CRM
for problem C3.5 of that workshop. It is available as `crm_q3.msh` in
<https://www1.grc.nasa.gov/wp-content/uploads/C3.5_gridfiles.zip>, is given in
Gmsh [3] format with all lengths in inches, and represents the geometry with
piecewise cubic (Q3) 64-node hexahedra.

Daniel Doehring prepared that mesh for the simulations of Section 5.5 of [4]:
the elements were truncated to their straight-sided (linear) counterparts by
keeping only the eight corner nodes of each hexahedron, the remaining nodes
were relabeled consecutively, all coordinates were converted from inches to
meters (a scaling by exactly 0.0254), and the result was written in Abaqus
format. The element and boundary structure of the original mesh - including the
names of the seven boundary sets - is preserved. The resulting mesh is
published as `5_Applications/5_5_CommonResearchModel/crm_q3_lin_relabel_m.inp`
in the reproducibility repository [5] of the article [4]. The file distributed
here differs only in the comment of the `*Heading` line, which names the origin
of the mesh in the version distributed here; the mesh itself is byte-for-byte
identical.

# How to cite

When you use this mesh, please cite all the sources that it builds upon:

1. J. Vassberg, M. DeHaan, M. Rivers, R. Wahls (2008).
   Development of a Common Research Model for Applied CFD Validation Studies.
   26th AIAA Applied Aerodynamics Conference, Honolulu, Hawaii,
   AIAA Paper 2008-6919.
   [DOI: 10.2514/6.2008-6919](https://doi.org/10.2514/6.2008-6919)
2. H. T. Huynh (2015).
   Third International Workshop on High-Order CFD Methods.
   NASA Glenn Research Center.
   The workshop page
   <https://www1.grc.nasa.gov/research-and-engineering/hiocfd/>
   no longer lists the individual problems; the description of problem C3.5 and
   the grid files remain available at
   <https://www1.grc.nasa.gov/wp-content/uploads/case_c3.5.pdf> and
   <https://www1.grc.nasa.gov/wp-content/uploads/C3.5_gridfiles.zip>.
3. C. Geuzaine, J.-F. Remacle (2009).
   Gmsh: A 3-D finite element mesh generator with built-in pre- and
   post-processing facilities.
   International Journal for Numerical Methods in Engineering 79, pp. 1309-1331.
   [DOI: 10.1002/nme.2579](https://doi.org/10.1002/nme.2579)
4. D. Doehring, H. Ranocha, M. Torrilhon (2025).
   Paired Explicit Relaxation Runge-Kutta Methods: Entropy-Conservative and
   Entropy-Stable High-Order Optimized Multirate Time Integration.
   [DOI: 10.48550/arXiv.2507.04991](https://doi.org/10.48550/arXiv.2507.04991)
5. D. Doehring, H. Ranocha, M. Torrilhon (2025).
   Reproducibility repository for "Paired Explicit Relaxation Runge-Kutta
   Methods: Entropy-Conservative and Entropy-Stable High-Order Optimized
   Multirate Time Integration".
   [DOI: 10.5281/zenodo.15601890](https://doi.org/10.5281/zenodo.15601890)

The corresponding BibLaTeX entries are

```bibtex
@inproceedings{vassberg2008development,
  title={Development of a {C}ommon {R}esearch {M}odel for Applied
         {CFD} Validation Studies},
  author={Vassberg, John and DeHaan, Mark and Rivers, Melissa and
          Wahls, Richard},
  booktitle={26th AIAA Applied Aerodynamics Conference},
  address={Honolulu, Hawaii},
  year={2008},
  month={08},
  note={AIAA Paper 2008-6919},
  doi={10.2514/6.2008-6919}
}

@misc{huynh2015third,
  title={Third International Workshop on High-Order {CFD} Methods},
  author={Huynh, Hung T.},
  year={2015},
  howpublished={\url{https://www1.grc.nasa.gov/research-and-engineering/hiocfd/}},
  note={NASA Glenn Research Center. Description of problem C3.5:
        \url{https://www1.grc.nasa.gov/wp-content/uploads/case_c3.5.pdf}}
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

The mesh file is redistributed (modifying only the comment of the `*Heading` line)
from the reproducibility repository [5],
<https://github.com/DanielDoehring/paper-2025-perrk>, where it is published under
the MIT license - like the source code of TrixiData.jl, but with a different
copyright holder. The license text is included in the artifact as `LICENSE`.

Since Julia artifacts must be downloadable as (compressed) tarballs while the
Gist serves the bare file, TrixiData.jl distributes the mesh file repackaged as
a `.tar.gz` archive, together with the license and a `README.md` written by the
authors of TrixiData.jl; see `Artifacts.toml`.
"""
function mesh_nasa_crm_hex_p1()
    return joinpath(artifact"mesh_nasa_crm_hex_p1",
                    "CRM_HIOCFD_2015_meters.inp")
end

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
used with [Trixi.jl](https://github.com/trixi-framework/Trixi.jl) as

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
artifact store; the mesh file itself is read-only, so copy it elsewhere if you
need to modify it. Note that some tools write derived files next to the mesh
file: the `P4estMesh` constructor of Trixi.jl, for example, creates
`..._preproc.inp` and `..._p4est_ready.inp` in the artifact directory. This
succeeds in a standard depot, but it modifies an artifact that is meant to be
immutable, so that `Pkg.Artifacts.verify_artifact` reports a mismatch
afterwards; with a read-only depot it fails. Copy the mesh file to a writable
directory first to avoid this. Next to the mesh file, the artifact directory
contains the license of the mesh (`LICENSE`) and a `README.md` repeating the
information given below.

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
artifact store; the mesh file itself is read-only, so copy it elsewhere if you
need to modify it. Note that some tools write derived files next to the mesh
file: the `P4estMesh` constructor of Trixi.jl, for example, creates
`..._preproc.inp` and `..._p4est_ready.inp` in the artifact directory. This
succeeds in a standard depot, but it modifies an artifact that is meant to be
immutable, so that `Pkg.Artifacts.verify_artifact` reports a mismatch
afterwards; with a read-only depot it fails. Copy the mesh file to a writable
directory first to avoid this.

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
