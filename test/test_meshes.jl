# The data sets are listed in alphabetical order.

@testitem "mesh_gingerbread_man" tags=[:artifacts] begin
    using SHA: sha256

    mesh_file = mesh_gingerbread_man()

    @test isfile(mesh_file)
    @test basename(mesh_file) == "mesh_gingerbread_man.mesh"
    # Make sure we got exactly the file published at
    # https://gist.github.com/andrewwinters5000/2c6440b5f8a57db131061ad7aa78ee2b
    @test bytes2hex(open(sha256, mesh_file)) ==
          "db0e5ffeedd1897cff9fc5cf1637e80eb309899e7b16ff90c2a968fc49b7be6e"

    # This artifact also contains everything needed to recreate the mesh
    @test sort(readdir(dirname(mesh_file))) == ["LICENSE.md", "Manifest.toml",
        "Project.toml", "README.md", "create_mesh.jl",
        "mesh_gingerbread_man.control", "mesh_gingerbread_man.mesh"]
end

@testitem "mesh_nasa_crm_hex_p1" tags=[:artifacts] begin
    using SHA: sha256

    mesh_file = mesh_nasa_crm_hex_p1()

    @test isfile(mesh_file)
    @test basename(mesh_file) == "CRM_HIOCFD_2015_meters.inp"
    # Make sure we got exactly the file published in the Gist
    # https://gist.github.com/DanielDoehring/fbc9d785909263ffec76983c4d520fe3
    @test bytes2hex(open(sha256, mesh_file)) ==
          "b9a01370a116c5e06f1baa570e51c94c86f32e29f4c62ccea3bf39d974c463f3"

    # The artifact contains the license of the mesh and a `README.md`
    # describing it, too
    artifact_dir = dirname(mesh_file)
    @test isfile(joinpath(artifact_dir, "LICENSE"))
    @test isfile(joinpath(artifact_dir, "README.md"))
end

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
