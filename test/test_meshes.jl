# The data sets are listed in alphabetical order.

@testitem "mesh_onera_m6_wing" tags=[:artifacts] begin
    using SHA: sha256

    mesh_file = mesh_onera_m6_wing()

    @test isfile(mesh_file)
    @test basename(mesh_file) == "ONERA_M6_sanitized.inp"
    # Make sure we got exactly the file published at
    # https://doi.org/10.5281/zenodo.15601890
    @test bytes2hex(open(sha256, mesh_file)) ==
          "e05e872d2c2b5edae3cfff8f9493d35edfd393048db9b33fb569480d0f6ba3d1"

    # The artifact contains the license of the source repository and a
    # `README.md` describing the mesh, too
    artifact_dir = dirname(mesh_file)
    @test isfile(joinpath(artifact_dir, "LICENSE"))
    @test isfile(joinpath(artifact_dir, "README.md"))
end

@testitem "mesh_tandem_spheres_hex_p2" tags=[:artifacts] begin
    using SHA: sha256

    mesh_file = mesh_tandem_spheres_hex_p2()

    @test isfile(mesh_file)
    @test basename(mesh_file) == "TandemSpheresHexMesh1P2_fixed.inp"
    # Make sure we got exactly the file published at
    # https://doi.org/10.5281/zenodo.18921889
    @test bytes2hex(open(sha256, mesh_file)) ==
          "2db6b8d583fc139120fd8a2d4c5d2fa4610f74b7f0e7c2372c6cecbe15884d5e"
end
