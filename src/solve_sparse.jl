export build_sparsity_pattern, solve_expo_sparse, build_variables


function dij(pb, i, j)
    return norm(pb.aero_to_coord[i, :] - pb.aero_to_coord[j, :])
end

function solve_expo_sparse(pb)
    m = Model(with_optimizer(GLPK.Optimizer))

    # m = Model(solver = GLPKSolverMIP(msg_lev = GLPK.MSG_ALL))

    n_aero = pb.n_aerodrome
    i_start = pb.start_aero
    i_end = pb.end_aero
    region_start = pb.aero_to_region[i_start]
    region_end = pb.aero_to_region[i_end]
    R = pb.airplane_range

    aero_set = Set(1:n_aero)


    ## One activation variable per edge
    xij = @variable m x[i in 1:n_aero, j in 1:n_aero; (dij(pb, i, j) < R) && (dij(pb, i, j) > 0)] Bin

    @show length(xij)

    # ## Going to the starting point is forbidden
    # @constraint m sum(x[i, i_start] for i ∈ setdiff(aero_set, i_start)) == 0
    ## One edge leaving the starting point
    @constraint m sum(xij[i, j] for (i,j) ∈ filter(x->x[1]==i_start, keys(xij))) >= 1


    # ## Similarly, going from the end point is forbidden
    # @constraint m sum(x[i_end, j] for j ∈ setdiff(aero_set, i_end)) == 0
    ## One edge leading to the end
    @constraint m sum(xij[i, j] for (i,j) ∈ filter(x->x[2]==i_end, keys(xij))) >= 1


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
            @constraint m sum(xij[i, j] for (i,j) ∈ filter(x->((x[1] ∈ region_pts) &&
                                                               (x[2] ∈ outregion_pts)), keys(xij))) >= 1
        end

        ## At least one edge entering current region (except for starting region)
        if region != region_start
            @constraint m sum(xij[i, j] for (i,j) ∈ filter(x->(x[1] ∈ outregion_pts) &&
                                                              (x[2] ∈ region_pts), keys(xij))) >= 1
        end

    end


    ## as many entering edges as leaving edges
    for i0 in setdiff(aero_set, Set([i_start, i_end]))
        @constraint m sum(xij[i, j] for (i,j) in filter(x->x[1]==i0, keys(xij))) -
                      sum(xij[i, j] for (i,j) in filter(x->x[2]==i0, keys(xij))) == 0
        ## NOTE: this can be done more efficiently, prefering readability for now.
    end

    ## Run through n_aero_parcour_min_min at least
    @constraint m sum(xij[i, j] for (i, j) ∈ keys(xij)) >= (pb.n_aero_parcour_min-1)
    ## NOTE: this can be done more efficiently, prefering readability for now.

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


    @objective m Min sum((xij[i, j] + xij[j, i]) * dij(pb, i, j) for (i, j) in filter(x->x[1]<x[2], keys(xij)))


    ## Optimizing and getting solver status, solution
    optimize!(m)

    @show JuMP.termination_status(m)

    @show JuMP.primal_status(m)
    # @show JuMP.dual_status(m)

    @show JuMP.objective_value(m)

    xsol = sparse(zeros(n_aero, n_aero))
    for ((i, j), var) in xij
        xsol[i, j] = JuMP.result_value(var)
    end

    pos_coeffs = Set()
    for i=1:size(xsol, 1), j=1:size(xsol, 2)
        if xsol[i, j] == 1
            push!(pos_coeffs, (i, j))
        end
    end
    @show pos_coeffs

    return xsol
end


function build_sparsity_pattern(pb)
    n = pb.n_aerodrome
    R = pb.airplane_range

    Is = Int[]
    Js = Int[]

    for j=1:n, i=1:n
        dist = dij(pb, i, j)
        if dist < R && dist > 0
            push!(Is, i)
            push!(Js, j)
        end
    end

    return Is, Js
end

function build_variables(pb, model)
    n = pb.n_aerodrome
    R = pb.airplane_range

    xij = @variable model x[i in 1:n, j in 1:n; (dij(pb, i, j) < R) && (dij(pb, i, j) > 0)] Bin
    return xij
end
