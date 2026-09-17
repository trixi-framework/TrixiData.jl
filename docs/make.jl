using Documenter
using DocumenterCodeBlocks: CodeBlocks
using Changelog: Changelog
using Artifacts: select_downloadable_artifacts
# `ensure_artifact_installed` is not part of the documented API
# of the `Artifacts` standard library since; it is part of the
# documented `Pkg.Artifacts` API (as of Julia 1.13).
using Pkg.Artifacts: ensure_artifact_installed

# Get TrixiData.jl root directory
trixidata_root_dir = dirname(@__DIR__)

# Fix for https://github.com/trixi-framework/Trixi.jl/issues/668
if (get(ENV, "CI", nothing) != "true") &&
   (get(ENV, "TRIXIDATA_DOC_DEFAULT_ENVIRONMENT", nothing) != "true")
    push!(LOAD_PATH, trixidata_root_dir)
end

using TrixiData

# Install all (lazy) artifacts of TrixiData.jl before building the documentation.
# Otherwise, the progress information that Julia prints while downloading an
# artifact would end up in the captured output of the doctests using it and let
# them fail. This is the snippet recommended in the docstring of the deprecated
# `Pkg.Artifacts.ensure_all_artifacts_installed`; going through
# `select_downloadable_artifacts` keeps this working automatically when new data
# sets are added and skips artifacts that are not available for this platform.
let artifacts_toml = joinpath(trixidata_root_dir, "Artifacts.toml")
    artifacts = select_downloadable_artifacts(artifacts_toml; include_lazy = true)
    for name in keys(artifacts)
        ensure_artifact_installed(name, artifacts[name], artifacts_toml)
    end
end

# Define module-wide setups such that the respective modules are available in doctests
DocMeta.setdocmeta!(TrixiData, :DocTestSetup, :(using TrixiData); recursive = true)

# Copy files from the repository root to not need to synchronize them manually
function copy_file(filename, replaces...; new_filename = lowercase(filename))
    content = read(joinpath(trixidata_root_dir, filename), String)
    content = replace(content, replaces...)

    header = """
    ```@meta
    EditURL = "https://github.com/trixi-framework/TrixiData.jl/blob/main/$filename"
    ```
    """
    content = header * content

    write(joinpath(@__DIR__, "src", new_filename), content)
end

copy_file("README.md",
          "[LICENSE.md](LICENSE.md)" => "[License](@ref)",
          new_filename = "index.md")
copy_file("AUTHORS.md",
          "in the [LICENSE.md](LICENSE.md) file" => "under [License](@ref)")
# Add section `# License` and add `>` in each line to add a quote
copy_file("LICENSE.md",
          "[AUTHORS.md](AUTHORS.md)" => "[Authors](@ref)",
          "\n" => "\n> ", r"^" => "# License\n\n> ")

# Create changelog
Changelog.generate(Changelog.Documenter(),                        # output type
                   joinpath(trixidata_root_dir, "NEWS.md"),       # input file
                   joinpath(@__DIR__, "src", "changelog_tmp.md"); # output file
                   repo = "trixi-framework/TrixiData.jl",         # default repository for links
                   branch = "main",)
# Fix edit URL of changelog
open(joinpath(@__DIR__, "src", "changelog.md"), "w") do io
    for line in eachline(joinpath(@__DIR__, "src", "changelog_tmp.md"))
        if startswith(line, "EditURL")
            line = "EditURL = \"https://github.com/trixi-framework/TrixiData.jl/blob/main/NEWS.md\""
        end
        println(io, line)
    end
end
# Remove temporary file
rm(joinpath(@__DIR__, "src", "changelog_tmp.md"))

# Make documentation
makedocs(modules = [TrixiData],
         sitename = "TrixiData.jl",
         # Provide additional formatting options
         format = Documenter.HTML(
                                  # Disable pretty URLs during manual testing
                                  prettyurls = get(ENV, "CI", nothing) == "true",
                                  # Explicitly add favicon as asset
                                  assets = ["assets/favicon.ico"],
                                  # Set canonical URL to GitHub pages URL
                                  canonical = "https://trixi-framework.github.io/TrixiData.jl/stable"),
         # Improve code blocks in the documentation by using DocumenterCodeBlocks.jl
         plugins = [CodeBlocks()],
         # Explicitly specify documentation structure
         pages = [
             "Home" => "index.md",
             "API reference" => "reference.md",
             "Development" => "development.md",
             "Changelog" => "changelog.md",
             "Authors" => "authors.md",
             "License" => "license.md"
         ])

deploydocs(repo = "github.com/trixi-framework/TrixiData.jl",
           devbranch = "main",
           # Only push previews if all the relevant environment variables are non-empty.
           push_preview = all(!isempty,
                              (get(ENV, "GITHUB_TOKEN", ""),
                               get(ENV, "DOCUMENTER_KEY", ""))))
