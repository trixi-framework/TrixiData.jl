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
