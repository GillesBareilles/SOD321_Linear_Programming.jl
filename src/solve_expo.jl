export solve_expo


function solve_expo(pb)
    m = Model(solver=CplexSolver(CPX_PARAM_MIPDISPLAY=1, CPX_PARAM_MIPINTERVAL=1))

    m, xij = build_base_model(pb, model=m)

    add_expo_subtourctr!(m, pb, xij)

    return m, xij
end


"""
    add_expo_subtourctr!(m, pb, xij)

Add exponential constraints to model in order to remove all subtours.
"""
function add_expo_subtourctr!(m, pb, xij)
    n_aero = pb.n_aerodrome
    i_start = pb.start_aero
    i_end = pb.end_aero

    aero_set = Set(1:n_aero)


    ## Eliminate all loops
    points_nostartend = setdiff(aero_set, Set([i_start, i_end]))

    n_soustours = 0
    for vertex_subset in setofallsubsets(points_nostartend)
        if length(vertex_subset) > 1
            @constraint m sum( xij[i, j] for (i, j) ∈ filter(x->(x[1] ∈ vertex_subset) &&
                                                                (x[2] ∈ vertex_subset), keys(xij))) <= (length(vertex_subset)-1)
            n_soustours += 1
        end
    end
    @show n_soustours
    nothing
end



"""
    ss = setofallsubsets(s::Set{<:Number})

Returns the set of all subsets of input `s`.
"""
function setofallsubsets(s::Set{T}) where {T<:Number}
    return set_termrec(s, Set{Set{Int}}( [Set{Int}()]  ))
end

function set_termrec(set, setofsets)
    if length(set) == 0
        return union(setofsets, Set{Int}())
    else
        x = pop!(set)
        setunionx = Set{Set{Int}}()
        for subset in setofsets
            push!(setunionx,union(subset, Set([x])))
        end
        union!(setofsets, setunionx)
        return set_termrec(set, setofsets)
    end

end
