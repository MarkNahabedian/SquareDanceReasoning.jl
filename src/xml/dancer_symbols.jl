
global DANCER_SYMBOLS = nothing

function load_dancer_symbols()
    doc = XML.read(joinpath(@__DIR__, "dancer_symbols.svg"), Node)
    filter(children(children(doc)[1])) do node
        XML.nodetype(node) == XML.Element && tag(node) == "symbol"
    end
end

function __init__()
    if DANCER_SYMBOLS == nothing
        global DANCER_SYMBOLS = load_dancer_symbols()
    end
end

