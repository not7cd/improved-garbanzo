push!(LOAD_PATH,"../src/")

using Documenter, ImprovedGarbanzo

makedocs(
    sitename="ImprovedGarbanzo",
    modules = [ImprovedGarbanzo],
    pages=[
        "Reference" => "reference.md"
    ],
)

deploydocs(
    repo = "github.com/not7cd/improved-garbanzo.git",
)
