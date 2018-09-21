module SOD321Project

greet() = print("Hello World!")

export Problem

struct Problem
    # Graph description
    n_aerodrome::Int
    n_regions::Int
    aero_to_region::Vector{Int}
    aero_to_coord::Vector{Tuple{Int, Int}}
    airplane_range::Int

    # Constraints data
    start_aero::Int         # index of starting aero
    end_aero::Int           # index of final aero
    n_aero_parcour::Int     # minimum number of aeros to go through
end

function Problem()
    return Problem(0, 0, Int[], Tuple{Int, Int}[], 0, 0, 0, 0)
end

include("input.jl")

end # module
