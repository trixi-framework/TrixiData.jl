# The data sets are listed in alphabetical order.

@testitem "topography_etopo_2022_surface_60s" tags=[:artifacts] begin
    using SHA: sha256

    topography_file = topography_etopo_2022_surface_60s()

    @test isfile(topography_file)
    @test basename(topography_file) == "ETOPO_2022_v1_60s_N90W180_surface.tif"
    # Make sure we got exactly the file published at
    # https://www.ngdc.noaa.gov/mgg/global/relief/ETOPO2022/data/60s/60s_surface_elev_gtif/ETOPO_2022_v1_60s_N90W180_surface.tif
    @test bytes2hex(open(sha256, topography_file)) ==
          "9d27d4b8ea8e76977e2988bca667d7c8fa68b927355feffcddd6b4875a7fd08e"

    # The artifact contains the license of the data and a `README.md`
    # describing them, too
    artifact_dir = dirname(topography_file)
    @test isfile(joinpath(artifact_dir, "LICENSE.md"))
    @test isfile(joinpath(artifact_dir, "README.md"))
end
