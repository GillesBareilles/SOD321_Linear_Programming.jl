module SOD321Project

using LinearAlgebra

using Plots

using JuMP, GLPK

include("types.jl")
include("input.jl")
include("plot.jl")

include("solve.jl")

end # module
