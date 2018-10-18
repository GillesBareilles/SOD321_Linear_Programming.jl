export get_loops_paths

"""
    loops, paths = get_loops_paths(arcs_to_treat)

Decompose the set of (oriented) arcs to treat into loops and (oriented) paths.
"""
function get_loops_paths(arcs_to_treat::OrderedSet{Array{Int64,1}})

    printall = 0
    # arcs_to_treat = OrderedSet(Array{Int64,1}[[19, 8], [11, 25], [25, 11], [20, 14], [14, 20], [7, 17], [1, 23], [15, 1], [17, 7], [4, 28], [8, 10], [28, 4], [23, 15]])

    (printall>0) && @show arcs_to_treat

    loops = OrderedSet{Vector{Int}}()
    paths = OrderedSet{Vector{Int}}()

    it = 0
        
    # one iteration: work in place on arcs_to_treat...
    n = length(arcs_to_treat)

    while length(arcs_to_treat) > 0 &&  it < n + 1

        (printall>0) && println("\n - current arcs_to_treat: $arcs_to_treat; length = $(length(arcs_to_treat))")
        (printall>0) && println(" - loops: $loops")
        
        arc = pop!(arcs_to_treat, first(arcs_to_treat))
        arc_updated = false

        (printall>0) && println(" - current arc: $arc")

        i_start, i_end = arc[1], arc[end]

        ## Run through arcs_to_treat
        for potential_neighbor in arcs_to_treat

            # If arc can be pre or appended to potential_neighbor, do so
            (printall>0) && println("       - dealing with $potential_neighbor")
            new_arc = Int[]
            if i_start == potential_neighbor[end]
                new_arc = vcat(potential_neighbor, arc[2:end])
            elseif i_end == potential_neighbor[1]
                new_arc = vcat(arc[1:end-1], potential_neighbor)
            end

            (printall>0) && println("       New arc = $new_arc")

            # If new arc is a loop, add to complete loops and remove from arcs to treat
            if length(new_arc)>0 
                delete!(arcs_to_treat, potential_neighbor)
                if new_arc[1] == new_arc[end]
                    push!(loops, new_arc[1:end-1])
                else
                    push!(arcs_to_treat, new_arc)
                end

                arc_updated = true
                break
            end
        end

        # if arc could not be added to any potential neighbor, problem...
        if !arc_updated
            (printall>0) && printstyled("   → Current arc $arc could not be updated;\n", color=:cyan)
            push!(paths, arc)
        end
        it = it + 1
    end

    if length(arcs_to_treat) > 0
        @error("get_loops_paths(): Decomposition stoped prematurely. Partial decomposition returned.")
    end

    # should be one arc remaining now, from start to end.
    (printall>0) && @show paths
    (printall>0) && @show loops
    
    return loops, paths
end
