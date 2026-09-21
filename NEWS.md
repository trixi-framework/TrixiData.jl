# Changelog

TrixiData.jl follows the interpretation of
[semantic versioning (semver)](https://julialang.github.io/Pkg.jl/dev/compatibility/#Version-specifier-format-1)
used in the Julia ecosystem. Notable changes will be documented in this file
for human readability.

This changelog also covers the data sets distributed by TrixiData.jl: adding a
new data set is a feature, while changing the content returned by an existing
accessor function - or removing such a function - is a breaking change.

<!-- Template: below a heading of the form `## Changes in the vX.Y lifecycle`
     or `## Changes when updating to vX.Y from vX.(Y-1).z`, use the section
     headings `#### Added`, `#### Changed`, `#### Deprecated`, and
     `#### Removed` in this order, omitting the empty ones. A pull request is
     referenced by writing its number with a leading hash sign in square
     brackets; Changelog.jl turns that into a link when building the
     documentation. -->


## Changes in the v0.1 lifecycle

#### Added

- `mesh_tandem_spheres_hex_p2` returns the path to a mesh of the tandem spheres
  configuration (case CS1 of the High-Order CFD Workshop) in Abaqus format,
  consisting of 31,616 curved hexahedral elements of polynomial degree two.
  The mesh is distributed as a lazy artifact and is taken from
  [DOI: 10.5281/zenodo.18921889](https://doi.org/10.5281/zenodo.18921889)
  (Daniel Doehring, CC BY 4.0).
- `mesh_onera_m6_wing` returns the path to a sanitized mesh of the ONERA M6
  wing in Abaqus format, consisting of 294,838 straight-sided hexahedral
  elements. The mesh is distributed as a lazy artifact and is taken from
  [DOI: 10.5281/zenodo.15601890](https://doi.org/10.5281/zenodo.15601890)
  (Daniel Doehring, Hendrik Ranocha, Manuel Torrilhon, MIT license).
- `mesh_nasa_crm_hex_p1` returns the path to a mesh of the NASA Common
  Research Model (CRM) in Abaqus format, consisting of 79,505 straight-sided
  hexahedral elements. The mesh is distributed as a lazy artifact and is taken
  from [DOI: 10.5281/zenodo.15601890](https://doi.org/10.5281/zenodo.15601890)
  (Daniel Doehring, Hendrik Ranocha, Manuel Torrilhon, MIT license).
- `mesh_gingerbread_man` returns the path to a two-dimensional mesh of a
  gingerbread man in HOHQMesh's ISM-V2 format, consisting of 903 curved
  quadrilateral elements with boundary curves of polynomial degree six.
  The mesh is distributed as a lazy artifact and is taken from
  [this gist](https://gist.github.com/andrewwinters5000/2c6440b5f8a57db131061ad7aa78ee2b)
  (Andrew R. Winters, MIT). Its artifact also contains the control file, a Julia
  environment, and a script to recreate the mesh.
