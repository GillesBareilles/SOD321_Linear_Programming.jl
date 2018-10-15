export solve_poly


function solve_poly(pb)
    m = Model(solver=CplexSolver()) ## CPX_PARAM_MIPDISPLAY=1, CPX_PARAM_MIPINTERVAL=1

    m, xij = build_base_model(pb, model=m)

    add_poly_subtourctr!(m, pb, xij)

    xsol = solve_model(m, pb, xij)

    return xsol
end


"""
    add_poly_subtourctr!(m, pb, xij)

Add exponential constraints to model in order to remove all subtours.
"""
function add_poly_subtourctr!(m, pb, xij)
    n_aero = pb.n_aerodrome

    @variable m u[1:n_aero] Int



    for (i, j) in keys(xij)
        @constraint m u[j] - u[i] + n_aero * (1 - xij[i, j]) ≥ 1
    end

    nothing
end
