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
    n_aero_parcour::Int     # minimum number of aeros to go through
end

function Problem()
    return Problem(0, 0, Int[], Array{Int, 2}(undef, 0, 0), 0, 0, 0, 0)
end

function show(io::IO, pb::Problem)
    println(io, "- SOD321 instance with:")
    println(io, rpad("n_aerodrome", 20), lpad(pb.n_aerodrome, 8))
    println(io, rpad("n_regions", 20), lpad(pb.n_regions, 8))
    println(io, rpad("airplane_range", 20), lpad(pb.airplane_range, 8))
    println(io, rpad("n_aero_parcour", 20), lpad(pb.n_aero_parcour, 8))
    println(io, rpad("aero_to_region", 20))
    println(pb.aero_to_region)
    println(io, rpad("aero_to_coord", 20))
    display(pb.aero_to_coord)
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
