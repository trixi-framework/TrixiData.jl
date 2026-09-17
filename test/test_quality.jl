@testitem "Aqua.jl" tags=[:quality] begin
    using Aqua: Aqua

    Aqua.test_all(TrixiData)
end

@testitem "ExplicitImports.jl" tags=[:quality] begin
    using ExplicitImports: check_no_implicit_imports, check_no_stale_explicit_imports

    @test isnothing(check_no_implicit_imports(TrixiData))
    # `LazyArtifacts` is loaded only to enable the download of lazy artifacts,
    # see the comment in src/TrixiData.jl
    @test isnothing(check_no_stale_explicit_imports(TrixiData,
                                                    ignore = (:LazyArtifacts,)))
end
