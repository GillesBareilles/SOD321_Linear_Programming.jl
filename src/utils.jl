import Base: show
export show, dij


function Problem()
    return Problem(0, 0, Int[], zeros(1,1), 0, 0, 0, 0)
end

function show(io::IO, pb::Problem)
    xmin = minimum(pb.aero_to_coord[:, 1])
    ymin = minimum(pb.aero_to_coord[:, 2])
    xmax = maximum(pb.aero_to_coord[:, 1])
    ymax = maximum(pb.aero_to_coord[:, 2])

    println(io, "- SOD321 instance with:")
    println(io, rpad("n_aerodrome", 20), lpad(pb.n_aerodrome, 8))
    println(io, rpad("n_regions", 20), lpad(pb.n_regions, 8))
    println(io, rpad("airplane_range", 20), lpad(pb.airplane_range, 8))
    print(io, rpad("regions", 26))
    println(collect(SortedSet(pb.aero_to_region)))
    println(io, rpad("space", 26), "[$xmin, $xmax]×[$ymin, $ymax]")
    println(io, rpad("n_aero_parcour_min", 20), lpad(pb.n_aero_parcour_min, 8))
    println(io, rpad("start_aero", 20), lpad(pb.start_aero, 8))
    println(io, rpad("end_aero", 20), lpad(pb.end_aero, 8))
    nothing
end

function get_distance(pb::Problem, sol::Vector{Int})
    @assert length(sol) >= 2
    dist = 0.0

    cur_pt = pb.aero_to_coord[sol[1], :]
    for i=2:length(sol)
        next_pt = pb.aero_to_coord[sol[i], :]

        dist += norm(cur_pt - next_pt)
        cur_pt = next_pt
    end

    return dist
end

function dij(pb, i, j)
    return round(norm(pb.aero_to_coord[i, :] - pb.aero_to_coord[j, :]))
end

function sol_to_arcs(xijs)
    arcs_to_treat = OrderedSet{Array{Int64,1}}()
    for (i, j) in keys(xijs)
        if abs(xijs[i, j]) > 0.5
            push!(arcs_to_treat, [i, j])
        end
    end
    return arcs_to_treat
end

function certify_sol(pb::Problem, xsol)
    arcs = sol_to_arcs(xsol)
    loops, paths = get_loops_paths(arcs)

    if length(loops) > 0 || length(paths) != 1
        @show length(loops)
        @show length(paths)
        return false
    end

    path = first(paths)

    # Check first and final aeros
    if path[1] != pb.start_aero || path[end] != pb.end_aero
        @show path[1], pb.start_aero
        @show path[end], pb.end_aero
        return false
    end

    # Check that all aeros are in range
    for i in 1:length(path)-1
        if dij(pb, path[i], path[i+1]) > pb.airplane_range
            @show dij(pb, path[i], path[i+1]), pb.airplane_range
            return false
        end
    end

    # Check that min nb of aeros is run through
    if length(path) < pb.n_aero_parcour_min
        @show length(path), pb.n_aero_parcour_min
        return false
    end


    # Check that all regions have been run through
    region_to_nbaero = Dict(i=>0 for i in Set(pb.aero_to_region))
    for aero in path
        region_to_nbaero[pb.aero_to_region[aero]] += 1
    end

    for (region, nbaero) in region_to_nbaero
        if (nbaero == 0) && (region != 0)
            @show region, nbaero
            return false
        end
    end

    return true
end