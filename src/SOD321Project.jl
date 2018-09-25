module SOD321Project

using LinearAlgebra, SparseArrays

using Plots

using JuMP, GLPK

include("types.jl")
include("input.jl")
include("plot.jl")

include("solve.jl")
include("solve_sparse.jl")

end # module
