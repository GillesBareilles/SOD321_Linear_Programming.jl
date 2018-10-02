module SOD321Project

using LinearAlgebra, SparseArrays

# using Plots

using JuMP, GLPK, Cbc

include("types.jl")
include("input.jl")
# include("plot.jl")

include("solve.jl")
include("solve_sparse.jl")
include("solve_poly_sparse.jl")

include("generate_instance.jl")

end # module
