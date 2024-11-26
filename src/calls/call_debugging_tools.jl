# Tools for debugging square dance calls and their execution.

export CallEngineDebugContext, @CallEngineDebugContext


"""
    CallEngineDebugContext(source_location, relpath, token)

A CallEngineDebugContext can be passed to some functions via the
`dbgctx` keyword argument to provide debugging support.

Do not use the constructor directly, instead use
[`@CallEngineDebugContext`](@ref), which will automatically provide a
source location.
"""
struct CallEngineDebugContext
    source_location::LineNumberNode
    relpath
    token::String
end


"""
    @CallEngineDebugContext(relpath, token)

Creates a [`CallEngineDebugContext`](@ref) with an appropriate source
locator.
"""
macro CallEngineDebugContext(relpath, token)
    :(CallEngineDebugContext($(QuoteNode(__source__)),
                             $relpath, $token))
end


function choreography_debug_title(ctx::CallEngineDebugContext, time)
    line_number = ctx.source_location.line
    source_file = string(ctx.source_location.file)
    dir, file = splitdir(source_file)
    base, _ = splitext(file)
    timestr = @sprintf("%04d", time)
    return (joinpath(dir, splitpath(ctx.relpath)...),
            "$(base)_$(line_number)_$(ctx.token)_$timestr")
end

function write_debug_formation_file(dbgctx::Nothing,
                                    kb::SDRKnowledgeBase, time)
end

function write_debug_formation_file(dbgctx::CallEngineDebugContext,
                                    kb::SDRKnowledgeBase, time)
    dir, title = choreography_debug_title(dbgctx, time)
    filepath = joinpath(dir, title * ".html")
    write_formation_html_file(title, filepath, kb::SDRKnowledgeBase)
    println("\nwrite_debug_formation_file wrote $filepath")
end

