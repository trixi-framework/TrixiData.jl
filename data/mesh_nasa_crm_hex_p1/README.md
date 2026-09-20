# NASA CRM mesh with straight-sided hexahedra

This is the content of the Julia artifact `mesh_nasa_crm_hex_p1` distributed by
[TrixiData.jl](https://github.com/trixi-framework/TrixiData.jl). It contains

- `CRM_HIOCFD_2015_meters.inp`: the mesh, redistributed unmodified from the
  source given below,
- `LICENSE`: the license under which the mesh is published,
- `README.md`: this file, written by the authors of TrixiData.jl.


## The mesh

The NASA Common Research Model (CRM) [1] is a contemporary transonic transport
configuration designed as a common geometry for CFD validation studies. This
mesh discretizes the wing-body variant of the CRM at full scale with all
lengths given in meters; the wing reference chord is 7.005 m. The flow
direction is `x`, the wing spans in `y`, and `z` points upwards, so that the
plane `y = 0` is the symmetry plane of the aircraft. The aircraft surface
extends from 2.36 to 65.10 in `x`, from 0 to 29.46 in `y`, and from 2.31 to
8.72 in `z`.

The surrounding domain is the half `y >= 0` of a bullet-shaped region of radius
R = 7005.32 m, i.e., 1000 reference chords: a hemispherical cap around the
origin ahead of the aircraft (`x <= 0`, `x^2 + y^2 + z^2 = R^2`), continued
downstream as a circular cylinder around the `x` axis (`y^2 + z^2 = R^2`) and
closed by the outflow plane `x = R`.

The mesh is given in Abaqus format (`.inp`) and consists of 85,093 nodes and
79,505 straight-sided hexahedral elements (8-node elements of Abaqus type
`C3D8`) forming the element set `Volume0`. The boundaries are discretized by
10,984 additional quadrilateral surface elements (4-node elements of Abaqus
type `CPS4`) in the element sets `Surface1` to `Surface7`, which are also
available under the descriptive names

| Name       | Boundary                             | Elements | Nodes |
|:-----------|:-------------------------------------|---------:|------:|
| `FUSELAGE` | fuselage surface                     |    2,354 | 2,448 |
| `WING`     | blunt trailing edge and wing tip     |      412 |   447 |
| `WING_UP`  | upper wing surface                   |      238 |   270 |
| `WING_LO`  | lower wing surface                   |      206 |   236 |
| `SYMMETRY` | symmetry plane `y = 0`               |    2,632 | 2,792 |
| `FARFIELD` | hemispherical cap and cylinder       |    4,019 | 4,121 |
| `OUTFLOW`  | outflow plane `x = 7005.32`          |    1,123 | 1,180 |

as both node sets (`*NSET`) and element sets (`*ELSET`); the element counts
above are those of the blocks `Surface1` to `Surface7`. Neighboring boundaries
share the nodes along their common edges.

The element sets are inherited unchanged from the original grid described below
and one of them is defective: the element set `FUSELAGE` lists the volume
element 3509 instead of the surface element 81859, which is the last element of
the corresponding block `*ELEMENT, type=CPS4, ELSET=Surface1`. The node sets
are not affected. This matters only for tools that read the element sets;
[Trixi.jl](https://github.com/trixi-framework/Trixi.jl), for example,
identifies boundaries via the node sets.

This mesh is very coarse for the transonic viscous flow it is usually applied
to; it is used in [4] to demonstrate time integration methods rather than to
resolve the flow accurately.


## Origin

For the third International Workshop on High-Order CFD Methods [2] held in
2015, Marco Ceze (University of Michigan) provided a hexahedral mesh of the
CRM for problem C3.5 of that workshop. It is available as `crm_q3.msh` in
<https://www1.grc.nasa.gov/wp-content/uploads/C3.5_gridfiles.zip>, is given in
Gmsh [3] format with all lengths in inches, and represents the geometry with
piecewise cubic (Q3) 64-node hexahedra.

Daniel Doehring prepared that mesh for the simulations of Section 5.5 of [4]:
the elements were truncated to their straight-sided (linear) counterparts by
keeping only the eight corner nodes of each hexahedron, the remaining nodes
were relabeled consecutively, all coordinates were converted from inches to
meters (a scaling by exactly 0.0254), and the result was written in Abaqus
format. The element and boundary structure of the original mesh - including
the names of the seven boundary sets - is preserved. The resulting mesh is
published as `5_Applications/5_5_CommonResearchModel/crm_q3_lin_relabel_m.inp`
in the reproducibility repository [5] of the article [4]. The file distributed
here differs only in the comment of the `*Heading` line, which names the origin
of the mesh in the version distributed here; the mesh itself is byte-for-byte
identical.


## How to cite

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


## License

The mesh file is redistributed (modifying only the comment of the `*Heading` line)
from the reproducibility repository [5],
<https://github.com/DanielDoehring/paper-2025-perrk>, where it is published under
the MIT license; see `LICENSE`.
