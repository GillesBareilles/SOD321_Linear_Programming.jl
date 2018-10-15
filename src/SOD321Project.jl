module SOD321Project

using LinearAlgebra, SparseArrays, DataStructures

# using Plots

using JuMP

using CPLEX

include("types.jl")
include("input.jl")
# include("plot.jl")

include("build_base_model.jl")

include("solve_expo.jl")
include("solve_expo_lazy.jl")

include("solve_poly.jl")

## Old irrelevant stuff
# include("solve.jl")
# include("solve_expo_sparse.jl")
# include("solve_poly_sparse.jl")

# include("generate_instance.jl")

# include("build_poly_constraints.jl")

end # module
