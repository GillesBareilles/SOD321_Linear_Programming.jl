export build_base_model, solve_model

"""
    model = build_base_model!(model = Model(with_optimizer(Cbc.CbcOptimizer)))

Builds upon `model` the variables and the following constraints for the given instance:
- one edge leaving the starting point
- one edge leading to the end point
- At least one edge exiting each region, except for region 0 and of final point
- At least one edge entering each region, except for region 0 and of starting point
- for each node, flow conservation
- for each node, entering and leaving flow bounded by 1 (good for continuous relaxations)
- Run through the minimum number of aeros.
"""
function build_base_model(pb::Problem; model = Model(with_optimizer(Cbc.CbcOptimizer)))
    # model = Model(with_optimizer(Cbc.CbcOptimizer))

    n_aero = pb.n_aerodrome
    i_start = pb.start_aero
    i_end = pb.end_aero
    region_start = pb.aero_to_region[i_start]
    region_end = pb.aero_to_region[i_end]
    R = pb.airplane_range

    aero_set = Set(1:n_aero)


    # One activation variable per edge
    xij = @variable model x[i in 1:n_aero, j in 1:n_aero; (dij(pb, i, j) < R) && (dij(pb, i, j) > 0)] Bin



    # One edge leaving the starting point
    @constraint model sum(xij[i, j] for (i,j) ∈ filter(x->x[1]==i_start, keys(xij))) == 1
    # One edge leading to the end
    @constraint model sum(xij[i, j] for (i,j) ∈ filter(x->x[2]==i_end, keys(xij))) == 1

    # Constraint per sector
    regions = Set(pb.aero_to_region)
    delete!(regions, 0)

    region_to_pts = Dict{Int, Set{Int}}([region => Set{Int}() for region in regions])

    for (i_aero, region) in enumerate(pb.aero_to_region)
        if region > 0
            push!(region_to_pts[region], i_aero)
        end
    end

    for (region, region_aero) in region_to_pts
        outregion_aero = setdiff(aero_set, region_aero)

        # At least one edge exiting current region (except for final region)
        if region != region_end
            @constraint model sum(xij[i, j] for (i,j) ∈ filter(x->((x[1] ∈ region_aero) &&
                                                               (x[2] ∈ outregion_aero)), keys(xij))) >= 1
        end

        # At least one edge entering current region (except for starting region)
        if region != region_start
            @constraint model sum(xij[i, j] for (i,j) ∈ filter(x->(x[1] ∈ outregion_aero) &&
                                                              (x[2] ∈ region_aero), keys(xij))) >= 1
        end

    end


    # as many entering edges as leaving edges
    for i0 in setdiff(aero_set, Set([i_start, i_end]))
        @constraint model sum(xij[i, j] for (i,j) in filter(x->x[1]==i0, keys(xij))) -
                      sum(xij[i, j] for (i,j) in filter(x->x[2]==i0, keys(xij))) == 0

        # At most one edge in, out
        @constraint model sum(xij[i, j] for (i,j) in filter(x->x[1]==i0, keys(xij))) <= 1
        @constraint model sum(xij[i, j] for (i,j) in filter(x->x[2]==i0, keys(xij))) <= 1
    end


    # Run through n_aero_parcour_min_min at least
    @constraint model sum(xij[i, j] for (i, j) ∈ keys(xij)) >= (pb.n_aero_parcour_min-1)


    @objective model Min sum((xij[i, j] + xij[j, i]) * dij(pb, i, j) for (i, j) in filter(x->x[1]<x[2], keys(xij)))


    add_poly_constraints!(pb, model, xij)

    return model, xij
end

function solve_model(pb, model, xij)
    n_aero = pb.n_aerodrome

    # Optimizing and getting solver status, solution
    optimize!(model)

    @show JuMP.termination_status(model)

    @show JuMP.primal_status(model)
    # @show JuMP.dual_status(model)

    @show JuMP.objective_value(model)

    xsol = sparse(zeros(n_aero, n_aero))
    for ((i, j), var) in xij
        xsol[i, j] = JuMP.result_value(var)
    end

    return xsol
end