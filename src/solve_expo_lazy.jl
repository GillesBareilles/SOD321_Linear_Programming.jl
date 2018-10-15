export solve_expo_lazy


function solve_expo_lazy(pb)
    m = Model(solver=CplexSolver(CPX_PARAM_MIPDISPLAY=1, CPX_PARAM_MIPINTERVAL=1))

    m, xij = build_base_model(pb, model=m)

    add_lazy_callback!(m, pb, xij)

    return m, xij
end

"""
    add_lazy_callback!(m, pb, xij)

set callback for dynamically adding lazy cuts.
"""
function add_lazy_callback!(m, pb, xij)
    println("yet to be done, cf tsp.jl")
end
