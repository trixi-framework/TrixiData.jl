# ONERA M6 wing mesh

This is the content of the Julia artifact `mesh_onera_m6_wing` distributed by
[TrixiData.jl](https://github.com/trixi-framework/TrixiData.jl). It contains

- `ONERA_M6_sanitized.inp`: the mesh, redistributed unmodified from the
  reproducibility repository given below,
- `LICENSE`: the license of that repository, which applies to the mesh file,
- `README.md`: this file, written by the authors of TrixiData.jl.


## The mesh

The ONERA M6 wing is a swept, semi-span wing without twist and one of the
classical validation cases for transonic external aerodynamics. The geometry
follows the experiments of Schmitt and Charpin [1] in the form used for CFD
simulations [2], i.e., with the finite trailing-edge thickness of the ONERA D
airfoil section closed to zero. All lengths are rescaled such that the nominal
span of the modeled semi-wing (b = 1.1963 m in [1, 2]) is one; around the tip,
the wing surface extends slightly beyond that, up to z ≈ 1.0168. The
surrounding domain extends from -6.373 to 7.411 in `x`, from -6.375 to 6.375 in
`y`, and from 0 to 7.373 in `z`, where the plane `z = 0` is the symmetry plane
of the wing.

The mesh is given in Abaqus format (`.inp`) and consists of 306,503 nodes and
294,838 straight-sided hexahedral elements (8-node elements of Abaqus type
`C3D8`) forming the element set `Volume1`. The node sets `Symmetry`,
`FarField`, `BottomWing`, and `TopWing` mark the symmetry plane, the outer
boundary, and the lower and upper wing surface, respectively. The airfoil
sections are symmetric and the trailing edge is closed, so `BottomWing` and
`TopWing` share the 139 nodes at which the lower and the upper surface meet.


## Origin

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


## How to cite

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


## License

The mesh file is redistributed unmodified from the reproducibility
repository [6], <https://github.com/DanielDoehring/paper-2025-perrk>, where it
is published under the MIT license; see `LICENSE`.
