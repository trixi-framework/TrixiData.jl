# `mesh_gingerbread_man`

The mesh file distributed as `mesh_gingerbread_man` is the one published as

> <https://gist.github.com/andrewwinters5000/2c6440b5f8a57db131061ad7aa78ee2b>

This directory provides that file and shows that it can be regenerated from the
control file `mesh_gingerbread_man.control` adapted from
[HOHQMesh.jl](https://github.com/trixi-framework/HOHQMesh.jl).

Run

```shell
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=. create_mesh.jl
```

in this directory. The script downloads the published mesh to
`mesh_gingerbread_man.mesh`, verifies its checksum, regenerates the mesh into
`run/`, and prints how far the two are apart.

It is written for **Julia v1.10** and was developed and tested with v1.10.12.
Besides Julia it needs `git`, `make`, and a Fortran compiler (`gfortran` by default,
override with the environment variable `FC`). Everything it builds, and the
regenerated mesh together with the plot and statistics files of the mesh
generator, end up in the subdirectory `run/`; delete it to start from scratch.


## What the script does

1. Download the published mesh file to `mesh_gingerbread_man.mesh` and check it
   against the known checksum. This is the file that is distributed; the
   remaining steps only verify where it comes from.

2. Check out commit `e7fada695ef83aecd172c945add5efd82baaaac1` (2021-05-06) of
   <https://github.com/trixi-framework/HOHQMesh> and commit
   `5a71c8b397d91ba04bc5bcc9da80162dcd1ff1ce` (2020-09-23) of
   <https://github.com/trixi-framework/FTObjectLibrary>. A released version of
   HOHQMesh.jl produces a (slightly) different mesh.

3. Build the mesh generator with the makefile shipped with that commit. Its
   paths have to be overridden, and it must not be run in parallel:

   ```shell
   make -f /path/to/HOHQMesh/HOHQMesh.mak \
        F90=gfortran \
        HOQMeshPath=/path/to/HOHQMesh \
        FTOLPath=/path/to/FTObjectLibrary
   ```

4. Compare `mesh_gingerbread_man.control` to `examples/GingerbreadMan.control`
   of the installed HOHQMesh.jl and print the lines in which the two differ. The
   script stops if anything but the expected lines has changed.

5. Run the resulting executable from this directory, since the output file names
   of the control file are relative to the working directory and the directories
   they name have to exist:

   ```shell
   mkdir -p run
   /path/to/HOHQMesh -f mesh_gingerbread_man.control
   ```

6. Compare the regenerated mesh to the published one. The script stops if the
   two differ in anything but the value of a coordinate.

7. Generate a mesh from the same control file with the HOHQMesh.jl version
   installed in this environment and print its size, so that the statement in
   step 2 can be checked as well.


## Expected result

```
Published mesh file - this is the file that is distributed
  mesh_gingerbread_man.mesh
  1067        1973         903           6
  sha256 db0e5ffeedd1897cff9fc5cf1637e80eb309899e7b16ff90c2a968fc49b7be6e

Regenerated mesh file
  run/mesh_gingerbread_man_regenerated.mesh
  1067        1973         903           6

Comparison with the published mesh
  number of lines                  8089
  lines that differ                 113
  non-numeric differences             0
  maximum relative difference   6.809e-16
```

The `sha256` of the regenerated mesh depends on the machine and is expected to
differ from the one of the published file. The two agree in the format marker
(`ISM-V2`), the header (1067 nodes, 1973 edges, 903 elements, polynomial
degree 6), the element connectivity, and all boundary names, and their
coordinates agree well within tolerances close to the precision of `Float64`.


## Source and license

The mesh describes a two-dimensional gingerbread man and is the example
`GingerbreadMan` of HOHQMesh. The distributed file is the one published in the
gist above, by Andrew R. Winters, which is the output of the HOHQMesh mesh
generator applied to the control file of that example.

The mesh and its control file are licensed under the MIT license
(Copyright (c) 2010-present David A. Kopriva and other contributors).
If you use it in your work, please cite

```bibtex
@article{kopriva2024hohqmesh:joss,
  title={{HOHQM}esh: An All Quadrilateral/Hexahedral Unstructured Mesh Generator
         for High Order Elements},
  author={David A. Kopriva and Andrew R. Winters and Michael Schlottke-Lakemper
          and Joseph A. Schoonover and Hendrik Ranocha},
  year={2024},
  journal={Journal of Open Source Software},
  doi={10.21105/joss.07476},
  volume={9},
  number={104},
  pages={7476},
  publisher={The Open Journal}
}
```
