export solve_poly_sparse, solve_poly_sparse_CR

function solve_poly_sparse(pb)
    m = Model(with_optimizer(GLPK.Optimizer, msg_lev = GLPK.MSG_ALL))

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
    @variable m u[1:n_aero] Int


    # HKM constraint: uj ≥ ui + 1 - n(1 - xij)
    for ((i, j), xij_var) in xij
        @constraint m u[j] - u[i] + n_aero * (1 - xij_var) ≥ 1
    end


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


    return xsol
end



function solve_poly_sparse_CR(pb)
    m = Model(with_optimizer(GLPK.Optimizer, msg_lev = GLPK.MSG_ALL))

    n_aero = pb.n_aerodrome
    i_start = pb.start_aero
    i_end = pb.end_aero
    region_start = pb.aero_to_region[i_start]
    region_end = pb.aero_to_region[i_end]
    R = pb.airplane_range

    aero_set = Set(1:n_aero)


    ## One activation variable per edge
    xij = @variable m x[i in 1:n_aero, j in 1:n_aero; (dij(pb, i, j) < R) && (dij(pb, i, j) > 0)] >= 0

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

    # ## Eliminate all loops
    # @variable m u[1:n_aero] Int
    #
    #
    # # HKM constraint: uj ≥ ui + 1 - n(1 - xij)
    # for ((i, j), xij_var) in xij
    #     @constraint m u[j] - u[i] + n_aero * (1 - xij_var) ≥ 1
    # end


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


    return xsol
end
