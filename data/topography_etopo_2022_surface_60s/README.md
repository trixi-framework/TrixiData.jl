# ETOPO 2022 ice surface elevation with a resolution of 60 arc-seconds

This is the content of the Julia artifact `topography_etopo_2022_surface_60s`
distributed by [TrixiData.jl](https://github.com/trixi-framework/TrixiData.jl).
It contains

- `ETOPO_2022_v1_60s_N90W180_surface.tif`: the elevation data, redistributed
  unmodified from the source given below,
- `LICENSE.md`: the license under which the data are published,
- `README.md`: this file, written by the authors of TrixiData.jl.


## The data

ETOPO 2022 [1] is a global relief model of the NOAA National Centers for
Environmental Information (NCEI): a seamless, gridded elevation model of the
whole Earth that combines the topography of the land with the bathymetry of the
oceans and of large lakes. It is the successor of ETOPO5, ETOPO2, and ETOPO1 and
is primarily used for coastal hazard and tsunami modeling. The model is
published at a resolution of 15 arc-seconds; the global grids with a resolution
of 30 and 60 arc-seconds are downsampled from it [2].

ETOPO 2022 comes in two versions, which differ only at the ice sheets of
Greenland and Antarctica: the *ice surface* version distributed here gives the
elevation of the top of the ice sheets, while the *bedrock* version gives the
elevation of the bedrock below them. At the South Pole, for example, the ice
surface is at 2,834 m, while the bedrock is at 6 m. Elsewhere, both versions
give the elevation of the bare earth, i.e., without vegetation and buildings.

The data cover the oceans as well: there, the elevations are negative and give
the depth of the sea floor. The file does not contain a land-sea mask, and the
sign of the elevation does not separate land from sea, since some land areas
such as the shore of the Dead Sea lie below sea level.

The file is a single-band GeoTIFF of 21,600 x 10,800 cells, i.e., one cell per
arc-minute, covering the whole globe from 180°W to 180°E and from 90°N to 90°S.
The first row is the northernmost one and the first column the westernmost one.
The grid is cell-registered (`AREA_OR_POINT=Area`): the value of the cell in
column `i` and row `j` (both counted from one) is the elevation at longitude
`-180 + (i - 1/2) / 60` and latitude `90 - (j - 1/2) / 60`. The elevations are
given in meters as 32-bit floating point numbers (`Float32`). The horizontal
datum is WGS84 and the elevations refer to the EGM2008 geoid, which is an
adequate approximation of mean sea level for most purposes (compound
coordinate reference system EPSG:9518). The tiles of ETOPO 2022 declare a
nodata value of -99999, which does not occur in the data. The elevations range
from -10,752.08 m in the Tonga Trench to 8,157.36 m in the cell containing
Mount Everest; like all extreme values, the height of Mount Everest is reduced
by the averaging over cells of one arc-minute.

The data are compressed internally (`DEFLATE`), so that the file needs roughly
466 MB of disk space and 933 MB of memory once read completely.


## Origin

The file is published by NCEI as
<https://www.ngdc.noaa.gov/mgg/global/relief/ETOPO2022/data/60s/60s_surface_elev_gtif/ETOPO_2022_v1_60s_N90W180_surface.tif>
and is linked from the landing page of ETOPO 2022,
<https://www.ncei.noaa.gov/products/etopo-global-relief-model>.
The data sources that ETOPO 2022 is compiled from are listed in its user
guide [2]. The file distributed here is that one, byte-for-byte.


## How to cite

When you use these data, please cite

1. NOAA National Centers for Environmental Information (2022).
   ETOPO 2022 15 Arc-Second Global Relief Model.
   NOAA National Centers for Environmental Information.
   [DOI: 10.25921/fd45-gt74](https://doi.org/10.25921/fd45-gt74)

This is the citation requested by NCEI for all resolutions of ETOPO 2022; NCEI
asks to add the date on which the data were accessed. The file distributed here
was downloaded on 2026-09-30. The data set is documented in

2. NOAA National Centers for Environmental Information (2022).
   ETOPO 2022 User Guide, revision 1.2.
   <https://www.ngdc.noaa.gov/mgg/global/relief/ETOPO2022/docs/1.2%20ETOPO%202022%20User%20Guide.pdf>

The corresponding BibLaTeX entry is

```bibtex
@misc{noaa2022etopo,
  title={{ETOPO} 2022 15 Arc-Second Global Relief Model},
  author={{NOAA National Centers for Environmental Information}},
  year={2022},
  publisher={NOAA National Centers for Environmental Information},
  doi={10.25921/fd45-gt74},
  urldate={2026-09-30}
}
```


## License

The data were produced by NOAA and are not subject to copyright protection in
the United States. NOAA waives any potential copyright and related rights in
these data worldwide through the Creative Commons Zero 1.0 Universal Public
Domain Dedication (CC0-1.0); see `LICENSE.md`. The data must not be used for
navigation.
