export add_poly_constraints!

function add_poly_constraints!(pb, model, xij)
    n_aero = pb.n_aerodrome


    ## Eliminate all loops
    @variable model u[1:n_aero] Int

    # HKM constraint: uj ≥ ui + 1 - n(1 - xij)
    for ((i, j), xij_var) in xij
        @constraint model u[j] - u[i] + n_aero * (1 - xij_var) ≥ 1
    end
end