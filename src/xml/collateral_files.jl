
# The generated XML and HTML files reference other files.  Here we
# ensure that those files are available in the same environment as the
# referencing files.

export copy_html_collateral_files, collateral_file_relpath

HTML_COLLATERAL_FILES = Dict(
    "dancer_symbols.svg" =>
        joinpath(@__DIR__, "dancer_symbols.svg"),
    # selection.js
)

TARGET_LOCATIONS = [
    pkgdir(SquareDanceReasoning),
    joinpath(pkgdir(SquareDanceReasoning), "docs", "src")
]


function working_splitpath(path)
    drive, rest = splitdrive(path)
    sp = splitpath(rest)
    if sp[1] == "\\"
        sp[1] = "/"
    end
    [ drive, sp... ]
end


"""
    copy_html_collateral_files()

Copies each of the files identified in HTML_COLLATERAL_FILES to each
of the directories listed in TARGET_LOCATIONS.

SquareDanceReasoning writes XML and HTML files to various locations.
Some of those locations are only accessible in certain circumstances.
For example, The package source code hierarchy is not available to
documentation foles delivered to the gh-pages branch.
`copy_html_collateral_files` copies the files to where they might be
needed.  `collateral_file_relpath` is used to file the most appropriate

Use [`collateral_file_relpath`](@ref) to get the best reference
location for a resource file.
"""
function copy_html_collateral_files()
    for target in TARGET_LOCATIONS
        if target == pkgdir(SquareDanceReasoning)
            continue
        end
        for file in values(HTML_COLLATERAL_FILES)
            _, fname = splitdir(file)
            cp(file, joinpath(target, fname))
        end
    end
end


"""
    collateral_file_relpath(resource_name, html_file_destination)

Returns the path to the named resource in the environment of
`html_file_destination`.

`resource_name` is one of the keys of `HTML_COLLATERAL_FILES`.

`html_file_destination` is the absolute path of the XML or HTML file
that is referring to the resource.
"""
function collateral_file_relpath(resource_name, html_file_destination)
   # Which of targets matches the longest prefix of
   # html_file_destination?
    splitdest = working_splitpath(html_file_destination)
    best_matched_to = 0
    best_target = missing
    for target in TARGET_LOCATIONS
        splittarget = working_splitpath(target)
        matched_to = paths_match_to(splitdest, splittarget)
        if matched_to > best_matched_to
            best_matched_to = matched_to
            best_target = target
        end
    end
    # We still need relative path from html_file_destination to
    # resource location:
    dir, _ = splitdir(html_file_destination)
    relpath(joinpath(best_target, resource_name), dir)
end


function paths_match_to(path1::Vector{String}, path2::Vector{String})
    m = min(length(path1), length(path2))
    for i in 1:m
        if path1[i] != path2[i]
            return i
        end
    end
    return m
end

