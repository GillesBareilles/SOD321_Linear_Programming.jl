# export solve_dumb

# function solve_dumb(pb::Problem)
#
#     m = Model(solver = GLPKSolverMIP(msg_lev = GLPK.MSG_ALL))
#     # m = Model(solver = KnitroSolver())
#
#     @variable m x[1:2]
#
#     @constraint m x[1]+x[2]<=6
#     @constraint m 9*x[1]+5*x[2]<=45
#
#     @objective m Max 8*x[1] + 5*x[2]
#
#     solve(m)
#     xsol = getvalue(m, x)
#
# end

function solve_poly(pb)
    m = Model(solver = GLPKSolverMIP(msg_lev = GLPK.MSG_ALL))

    n_aero = pb.n_aerodrome
    i_start = pb.start_aero
    i_end = pb.end_aero
    region_start = pb.aero_to_region[i_start]
    region_end = pb.aero_to_region[i_end]
    R = pb.airplane_range

    aero_set = Set(1:n_aero)

    ## One activation variable per edge
    @variable m x[1:n_aero, 1:n_aero] Bin

    ## looping over a point is not considered
    @constraint m [i=1:n_aero] x[i, i] == 0

    ## Going to the starting point is forbidden
    @constraint m sum(x[i, i_start] for i ∈ setdiff(aero_set, i_start)) == 0
    ## One edge leaving the starting point
    @constraint m sum(x[i_start, j] for j ∈ setdiff(aero_set, i_start)) == 1

    ## Similarly, going from the end point is forbidden
    @constraint m sum(x[i_end, j] for j ∈ setdiff(aero_set, i_end)) == 0
    ## One edge leading to the end
    @constraint m sum(x[i, i_end] for i ∈ setdiff(aero_set, i_end)) == 1


    ## Constraint per sector
    regions = Set(pb.aero_to_region)
    region_to_pts = Dict{Int, Set{Int}}([region => Set{Int}() for region in regions])

    for (i_aero, region) in enumerate(pb.aero_to_region)
        push!(region_to_pts[region], i_aero)
    end

    for (region, region_pts) in region_to_pts
        outregion_pts = setdiff(aero_set, region_pts)

        ## At least one edge exiting current region (except for final region)
        if region != region_end
            @constraint m sum(x[i, j] for i ∈ region_pts, j ∈ outregion_pts) >= 1
        end

        ## At least one edge entering current region (except for starting region)
        if region != region_start
            @constraint m sum(x[i, j] for i ∈ outregion_pts, j ∈ region_pts) >= 1
        end

    end


    ## Distance constraint
    for i=1:n_aero
        for j=1:(i-1)
            dij = norm(pb.aero_to_coord[i,:] - pb.aero_to_coord[j,:])
            @assert dij > 0

            @constraint m x[i, j] <= R / dij
            @constraint m x[j, i] <= R / dij
        end
    end


    ## as many entering edges as leaving edges
    for i0 in setdiff(aero_set, Set([i_start, i_end]))
        @constraint m sum(x[i0, j] for j in 1:n_aero) - sum(x[j, i0] for j in 1:n_aero) == 0
    end

    ## Run through n_aero_parcour_min_min at least
    @constraint m sum(i!=j?x[i, j]:0 for i ∈ aero_set, j ∈ aero_set) >= (pb.n_aero_parcour_min-1)


    ## Eliminate all loops
    points_nostartend = setdiff(aero_set, Set([i_start, i_end]))

    n_soustours = 0
    for vertex_subset in setofallsubsets(points_nostartend)
        if length(vertex_subset) > 1
            warn("subset = $vertex_subset")
            ctr = @constraint m sum( i!=j?x[i, j]:0 for i ∈ vertex_subset, j ∈ vertex_subset) <= (length(vertex_subset)-1)
            n_soustours += 1

            @show ctr
        end
    end
    @show n_soustours


    @objective m Min sum((x[i, j] + x[j, i]) * norm(pb.aero_to_coord[i, :] - pb.aero_to_coord[j, :]) for i=1:n_aero, j=1:i-1)

    # return m
    @show m

    solve(m)
    xsol = getvalue(x)

    pos_coeffs = Set()
    for i=1:size(xsol, 1), j=1:size(xsol, 2)
        if xsol[i, j] == 1
            push!(pos_coeffs, (i, j))
        end
    end
    @show pos_coeffs

    return xsol
end


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
