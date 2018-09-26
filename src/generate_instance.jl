export geninstance

function geninstance()
    n_aero = 100
    n_gridsize = 60

    aero_to_coord = zeros(n_aero, 2)
    aero_to_region = zeros(n_aero)

    pt_set = Set{Vector{Int}}()
    for i in 1:n_aero

        x, y = rand(1:n_gridsize), rand(1:n_gridsize)
        pt = [x, y]
        while pt in pt_set
            x, y = rand(1:n_gridsize), rand(1:n_gridsize)
            pt = [x, y]
        end
        push!(pt_set, pt)

        aero_to_coord[i, 1] = x
        aero_to_coord[i, 2] = y
    end
    @assert length(pt_set) == n_aero

    n_region = 1
    airplane_range = 10
    start_aero = 1
    end_aero = n_aero
    n_aero_parcours_min = 3

    pb = Problem(n_aero, n_region, aero_to_region, aero_to_coord,
                   airplane_range, start_aero, end_aero, n_aero_parcours_min)

    set_region!(pb, 0.7*n_gridsize, 1*n_gridsize, 0.7*n_gridsize, 1*n_gridsize)
    set_region!(pb, 0, 0.3*n_gridsize, 0*n_gridsize, 0.2*n_gridsize)

    return pb
end


function set_region!(pb, xmin, xmax, ymin, ymax)
    newregion = maximum(pb.aero_to_region) + 1

    for i in 1:pb.n_aerodrome
        x, y = pb.aero_to_coord[i, :]
        if xmin ≤ x ≤ xmax && ymin ≤ y ≤ ymax
            pb.aero_to_region[i] = newregion
        end
    end
end
