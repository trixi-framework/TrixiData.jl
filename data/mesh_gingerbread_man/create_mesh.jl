# Provide the mesh file distributed as `mesh_gingerbread_man` and verify that it
# can be regenerated from the control file `mesh_gingerbread_man.control` stored
# next to this script.
#
# The distributed file is the published one: it is downloaded to
# `mesh_gingerbread_man.mesh` and checked against a recorded checksum. The
# regenerated mesh goes to `run/` and is only used for the comparison, because
# its coordinates depend on the machine and the compiler it was produced with.
#
# Regenerating it needs the mesh generator as it was in May 2021: the mesh was
# created before the first release of HOHQMesh, and the curve discretization was
# changed afterwards, so no released version of HOHQMesh.jl reproduces it. This
# script therefore builds the historical mesh generator from source. See
# README.md for how to run it and what to expect.
#
# Run it from this directory as
#   julia --project=. create_mesh.jl

using Downloads: Downloads
using HOHQMesh: HOHQMesh, generate_mesh
using Printf: @printf
using SHA: sha256

# The mesh generator is built from the state of the HOHQMesh repository on
# 2021-05-06, the day the reference mesh was published. The mesh is unchanged up
# to 644657e21ca75faf5d0f92accd163df8bf89569b (2021-06-01); the next commit
# ae653520aef8f95b938a058e0ff6003a28c9e4fd rewrote the discretization of
# boundary curves and changes the result.
const HOHQMESH_URL = "https://github.com/trixi-framework/HOHQMesh.git"
const HOHQMESH_COMMIT = "e7fada695ef83aecd172c945add5efd82baaaac1"

# HOHQMesh needs the FTObjectLibrary; use the version that was current back then.
const FTOBJECTLIBRARY_URL = "https://github.com/trixi-framework/FTObjectLibrary.git"
const FTOBJECTLIBRARY_COMMIT = "5a71c8b397d91ba04bc5bcc9da80162dcd1ff1ce"

# The published mesh file. This is the file that is distributed; everything else
# in this directory only documents and verifies where it comes from.
const PUBLISHED_URL = "https://gist.githubusercontent.com/andrewwinters5000/2c6440b5f8a57db131061ad7aa78ee2b/raw/1f89fdf2c874ff678c78afb6fe8dc784bdfd421f/mesh_gingerbread_man.mesh"
const PUBLISHED_SHA256 = "db0e5ffeedd1897cff9fc5cf1637e80eb309899e7b16ff90c2a968fc49b7be6e"
const PUBLISHED_MESH_FILE = joinpath(@__DIR__, "mesh_gingerbread_man.mesh")

# The control file the mesh is generated from. It is
# `examples/GingerbreadMan.control` of HOHQMesh.jl with a few changes;
# `check_control_file` below verifies that they are the expected ones.
const CONTROL_FILE = joinpath(@__DIR__, "mesh_gingerbread_man.control")

# The lines of `examples/GingerbreadMan.control` that CONTROL_FILE changes: the
# three output file names, the mesh file format, and the name of the curve of
# the chain `Eye2`.
const CHANGED_CONTROL_FILE_LINES = [4, 5, 6, 7, 179]

# In the ISM-V2 format, the header, the edge and element connectivity, and the
# boundary flags are written as integers while the coordinates are written in
# floating point; the two never appear in the same line. Integers therefore
# describe the structure of the mesh and have to match exactly, while
# coordinates may differ by round-off.
const INTEGER_TOKEN = r"^[+-]?\d+$"

# The published mesh was produced years ago by a Fortran program built with
# another compiler on another machine, so its coordinates differ from the ones
# regenerated here in the last digits; the largest relative difference observed
# is 7e-16. The tolerances below leave room for the round-off of a different
# compiler while staying far below any genuine difference between two meshes,
# whose coordinates differ in the leading digits.
const COORDINATE_RTOL = 1.0e-10
const COORDINATE_ATOL = 1.0e-10

# Fortran compiler; `-cpp -O` (the default `FFLAGS` of the historical makefile)
# must work with it.
const FC = get(ENV, "FC", "gfortran")

# Everything is built and run inside this directory. `run*/` is ignored by git.
const WORKDIR = joinpath(@__DIR__, "run")

"""
    checked_out_commit(directory)

Return the commit checked out in `directory`, or `nothing` if `directory` is not
a git repository with a commit checked out - which is what an interrupted
`checkout` leaves behind.
"""
function checked_out_commit(directory)
    return try
        readchomp(`git -C $directory rev-parse HEAD`)
    catch
        nothing
    end
end

"""
    checkout(url, commit, directory)

Check out `commit` of the git repository at `url` into `directory`, fetching
only that single commit. An existing checkout is reused if it is at `commit` and
discarded otherwise, so that neither an interrupted fetch nor a changed commit
leaves a stale state behind.
"""
function checkout(url, commit, directory)
    if isdir(directory)
        if checked_out_commit(directory) == commit
            @info "Reusing existing checkout" directory
            return directory
        end
        @info "Discarding incomplete or outdated checkout" directory
        rm(directory; recursive = true)
    end

    @info "Fetching repository" url commit
    mkpath(directory)
    run(`git -C $directory init --quiet`)
    run(`git -C $directory remote add origin $url`)
    run(`git -C $directory fetch --quiet --depth 1 origin $commit`)
    run(`git -C $directory checkout --quiet FETCH_HEAD`)

    return directory
end

"""
    build_mesh_generator(directory)

Build the HOHQMesh executable in `directory` and return the path to it.
"""
function build_mesh_generator(directory)
    hohqmesh_dir = checkout(HOHQMESH_URL, HOHQMESH_COMMIT,
                            joinpath(directory, "HOHQMesh"))
    ftol_dir = checkout(FTOBJECTLIBRARY_URL, FTOBJECTLIBRARY_COMMIT,
                        joinpath(directory, "FTObjectLibrary"))

    # An executable is only reused if it was built from the same sources with the
    # same compiler; the stamp records what it was built from.
    build_dir = joinpath(directory, "build")
    executable = joinpath(build_dir, "HOHQMesh")
    stamp_file = joinpath(build_dir, "build_stamp.txt")
    stamp = join((HOHQMESH_COMMIT, FTOBJECTLIBRARY_COMMIT, FC), "\n")
    if isfile(executable) && isfile(stamp_file) && read(stamp_file, String) == stamp
        @info "Reusing existing executable" executable
        return executable
    end

    # Build from scratch so that object files of a previous build cannot be
    # picked up by the one below.
    isdir(build_dir) && rm(build_dir; recursive = true)
    mkpath(build_dir)

    # The makefile shipped with this version of HOHQMesh has its paths hard-coded
    # for the machine of the original author; they are overridden on the command
    # line. `HOQMeshPath` is spelled like that in the makefile. `FFLAGS` is left
    # at its default `-cpp -O`.
    #
    # The makefile does not record all module dependencies, so it must not be
    # run in parallel.
    @info "Building the mesh generator" FC build_dir
    makefile = joinpath(hohqmesh_dir, "HOHQMesh.mak")
    cd(build_dir) do
        run(`make -f $makefile F90=$FC HOQMeshPath=$hohqmesh_dir FTOLPath=$ftol_dir`)
    end
    write(stamp_file, stamp)

    return executable
end

"""
    check_control_file(control_file)

Compare `control_file` to `examples/GingerbreadMan.control` of the installed
HOHQMesh.jl and print the lines in which the two differ. These must be exactly
the lines listed in `CHANGED_CONTROL_FILE_LINES`; anything else means that the
stored control file and the example have drifted apart.
"""
function check_control_file(control_file)
    original = joinpath(HOHQMesh.examples_dir(), "GingerbreadMan.control")
    ours = readlines(control_file)
    theirs = readlines(original)
    if length(ours) != length(theirs)
        error("`$control_file` has $(length(ours)) lines, `$original` has " *
              "$(length(theirs))")
    end

    changed_lines = [line for line in eachindex(ours) if ours[line] != theirs[line]]

    @printf("\n")
    @printf("Differences to %s\n", original)
    for line in changed_lines
        @printf("  line %3d  %s\n", line, strip(theirs[line]))
        @printf("        ->  %s\n", strip(ours[line]))
    end
    if changed_lines != CHANGED_CONTROL_FILE_LINES
        error("`$control_file` differs from `$original` in the lines " *
              "$changed_lines instead of $CHANGED_CONTROL_FILE_LINES")
    end

    return changed_lines
end

"""
    compare_with_published(mesh_file, published_file)

Compare `mesh_file` to `published_file` token by token and report how far the
two are apart. The two count as equal, and `true` is returned, only if

  - they have the same number of lines and the same number of tokens per line,
  - all tokens that are not coordinates are identical, so that the header, the
    connectivity, and the boundary names have to match exactly,
  - and every coordinate is finite in both files and equal to its counterpart
    within `COORDINATE_RTOL` and `COORDINATE_ATOL`.
"""
function compare_with_published(mesh_file, published_file)
    mesh = readlines(mesh_file)
    published = readlines(published_file)

    if length(mesh) != length(published)
        @error "Different number of lines" length(mesh) length(published)
        return false
    end

    differing_lines = 0
    differing_integers = 0
    differing_nonnumeric = 0
    nonfinite_coordinates = 0
    coordinates_out_of_tolerance = 0
    maximum_relative_difference = 0.0
    for (line, (a, b)) in enumerate(zip(mesh, published))
        a == b && continue
        differing_lines += 1

        tokens_a = split(a)
        tokens_b = split(b)
        if length(tokens_a) != length(tokens_b)
            differing_nonnumeric += 1
            @error "Different number of tokens in a line" line a b maxlog=10
            continue
        end

        for (ta, tb) in zip(tokens_a, tokens_b)
            ta == tb && continue

            # Anything that is written as an integer describes the structure of
            # the mesh, not a coordinate, and may not differ at all.
            if occursin(INTEGER_TOKEN, ta) || occursin(INTEGER_TOKEN, tb)
                differing_integers += 1
                @error "Integer token differs" line ta tb maxlog=10
                continue
            end

            # Fortran may write `D` instead of `E` for the exponent
            x = tryparse(Float64, replace(ta, 'D' => 'E', 'd' => 'e'))
            y = tryparse(Float64, replace(tb, 'D' => 'E', 'd' => 'e'))
            if x === nothing || y === nothing
                differing_nonnumeric += 1
                @error "Non-numeric token differs" line ta tb maxlog=10
                continue
            end

            if !isfinite(x) || !isfinite(y)
                nonfinite_coordinates += 1
                @error "Coordinate is not finite" line ta tb maxlog=10
                continue
            end

            # Both tokens can be zero while their spelling differs, e.g. `0.0`
            # and `-0.0`; without the guard that would give `NaN` here and `NaN`
            # would then swallow the maximum below.
            scale = max(abs(x), abs(y))
            relative_difference = iszero(scale) ? zero(scale) : abs(x - y) / scale
            maximum_relative_difference = max(maximum_relative_difference,
                                              relative_difference)

            if !isapprox(x, y; rtol = COORDINATE_RTOL, atol = COORDINATE_ATOL)
                coordinates_out_of_tolerance += 1
                @error "Coordinate outside of the tolerance" line ta tb maxlog=10
                continue
            end
        end
    end

    @printf("\n")
    @printf("Comparison with the published mesh\n")
    @printf("  number of lines                %6d\n", length(published))
    @printf("  lines that differ              %6d\n", differing_lines)
    @printf("  integer tokens that differ     %6d\n", differing_integers)
    @printf("  non-numeric tokens that differ %6d\n", differing_nonnumeric)
    @printf("  coordinates that are not finite%6d\n", nonfinite_coordinates)
    @printf("  coordinates out of tolerance   %6d\n", coordinates_out_of_tolerance)
    @printf("  maximum relative difference   %.3e\n", maximum_relative_difference)

    return differing_integers == 0 && differing_nonnumeric == 0 &&
           nonfinite_coordinates == 0 && coordinates_out_of_tolerance == 0
end

"""
    check_current_hohqmesh(directory, control_file)

Generate a mesh from `control_file` with the HOHQMesh.jl version installed in
this environment and report the size of the resulting mesh. This is the check
that the released versions cannot reproduce the published mesh.
"""
function check_current_hohqmesh(directory, control_file)
    # HOHQMesh stores output file names in a buffer of fixed length and silently
    # truncates longer ones, so keep the path it has to write short by passing a
    # relative output directory and running in this directory.
    output_directory = relpath(joinpath(directory, "current_hohqmesh"), @__DIR__)
    basename_control, _ = splitext(basename(control_file))
    mesh_file = cd(@__DIR__) do
        # `generate_mesh` returns the output of the mesh generator, not a file name
        generate_mesh(control_file; output_directory, verbose = false)
        abspath(joinpath(output_directory, basename_control * ".mesh"))
    end

    @printf("\n")
    @printf("Mesh generated by the installed HOHQMesh.jl v%s\n",
            pkgversion(HOHQMesh))
    @printf("  %s\n", strip(readlines(mesh_file)[2]))

    return mesh_file
end

"""
    download_published_mesh()

Download the published mesh file, the file that is distributed, and verify it
against `PUBLISHED_SHA256`.
"""
function download_published_mesh()
    if !isfile(PUBLISHED_MESH_FILE)
        @info "Downloading the published mesh" PUBLISHED_URL
        # Download next to the destination and move the file into place only
        # after it has been verified. An interrupted download can thus not leave
        # a truncated file behind that later runs would reuse.
        temporary_file = tempname(dirname(PUBLISHED_MESH_FILE))
        try
            Downloads.download(PUBLISHED_URL, temporary_file)
            checksum = bytes2hex(open(sha256, temporary_file))
            if checksum != PUBLISHED_SHA256
                error("the file downloaded from $PUBLISHED_URL has the sha256 " *
                      "$checksum instead of $PUBLISHED_SHA256")
            end
            mv(temporary_file, PUBLISHED_MESH_FILE)
        finally
            rm(temporary_file; force = true)
        end
    end

    checksum = bytes2hex(open(sha256, PUBLISHED_MESH_FILE))
    @printf("\n")
    @printf("Published mesh file - this is the file that is distributed\n")
    @printf("  %s\n", PUBLISHED_MESH_FILE)
    @printf("  %s\n", strip(readlines(PUBLISHED_MESH_FILE)[2]))
    @printf("  sha256 %s\n", checksum)
    if checksum != PUBLISHED_SHA256
        error("$PUBLISHED_MESH_FILE has the sha256 $checksum instead of " *
              "$PUBLISHED_SHA256; delete the file to download it again")
    end

    return PUBLISHED_MESH_FILE
end

"""
    regenerated_mesh_file(control_file)

Return the mesh file `control_file` writes, resolved relative to this directory,
which is the directory the mesh generator is run in.
"""
function regenerated_mesh_file(control_file)
    lines = readlines(control_file)
    index = findfirst(contains("mesh file name"), lines)
    if index === nothing
        error("`$control_file` does not contain a `mesh file name`")
    end

    name = strip(split(lines[index], '='; limit = 2)[2])

    return joinpath(@__DIR__, name)
end

function main()
    workdir = mkpath(WORKDIR)
    published_file = download_published_mesh()

    executable = build_mesh_generator(workdir)

    control_file = CONTROL_FILE
    check_control_file(control_file)

    # The output file names of the control file are relative to the working
    # directory, and they all point into `run/`: the regenerated mesh is only
    # used to verify the published one, it is not distributed.
    @info "Regenerating the mesh" executable control_file
    cd(@__DIR__) do
        run(`$executable -f $control_file`)
    end

    regenerated_file = regenerated_mesh_file(control_file)
    @printf("\n")
    @printf("Regenerated mesh file\n")
    @printf("  %s\n", regenerated_file)
    @printf("  %s\n", strip(readlines(regenerated_file)[2]))
    @printf("  sha256 %s\n", bytes2hex(open(sha256, regenerated_file)))

    # The checksums of the two files differ from machine to machine, so the
    # comparison is what decides whether the published file was reproduced.
    reproduced = compare_with_published(regenerated_file, published_file)

    check_current_hohqmesh(workdir, control_file)

    if !reproduced
        error("the regenerated mesh does not reproduce $published_file; " *
              "see the errors above")
    end

    return published_file
end

main()
