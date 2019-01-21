push!(LOAD_PATH,"../src/")

using Documenter, ImprovedGarbanzo

makedocs(
    sitename="ImprovedGarbanzo",
    modules = [ImprovedGarbanzo],
    pages=[
        "Start" => "index.md"
        "Reference" => "reference.md"
    ],
)

deploydocs(
    repo = "github.com/not7cd/improved-garbanzo.git",
)
