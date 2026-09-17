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
