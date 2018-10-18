module SOD321Project

using LinearAlgebra, SparseArrays, DataStructures

# using Plots

using JuMP

using CPLEX

using DataStructures

export Problem

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

include("utils.jl")
include("input.jl")
# include("plot.jl")
include("find_paths.jl")

include("build_base_model.jl")

include("solve_expo.jl")
include("solve_expo_lazy.jl")

include("solve_poly.jl")

end # module
