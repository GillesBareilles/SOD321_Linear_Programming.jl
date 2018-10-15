import Base: show
export Problem, show

struct Problem
    # Graph description
    n_aerodrome::Int
    n_regions::Int
    aero_to_region::Vector{Int}
    aero_to_coord::Array{Int, 2}
    airplane_range::Int

    # Constraints data
    start_aero::Int         # index of starting aero
    end_aero::Int           # index of final aero
    n_aero_parcour_min::Int     # minimum number of aeros to go through
end

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