# export plot_sol
using Plots


function plot_sol(pb::Problem)
    gr()
    n_aero = pb.n_aerodrome

    xstart, ystart = pb.aero_to_coord[pb.start_aero, :]
    xend, yend = pb.aero_to_coord[pb.end_aero, :]

    x = zeros(Int, n_aero-2)
    y = zeros(Int, n_aero-2)
    colors = zeros(Int, n_aero-2)
    i_arr = 1
    for i=1:n_aero
        if i ∉ Set([pb.start_aero, pb.end_aero])
            x[i_arr], y[i_arr] = pb.aero_to_coord[i, :]
            colors[i_arr] = pb.aero_to_region[i]
            i_arr += 1
        end
    end

    xmin, xmax = minimum(pb.aero_to_coord[:, 1]), maximum(pb.aero_to_coord[:, 1])
    ymin, ymax = minimum(pb.aero_to_coord[:, 2]), maximum(pb.aero_to_coord[:, 2])

    scatter(x, y, color=colors, xlims=[0, max(xmax, ymax)], ylims=[0, max(xmax, ymax)])
    scatter!([xstart], [ystart], color=color=pb.aero_to_region[pb.start_aero],
                                marker=:rect,
                                lab="start")
    scatter!([xend], [yend], color=pb.aero_to_region[pb.end_aero],
                                marker=:diamond,
                                lab="end")
    gui()
end

function plot_sol(pb::Problem, sol::Vector{Int})
    plot_sol(pb)

    xs = zeros(Int, length(sol))
    ys = zeros(Int, length(sol))
    for (i, pt_idx) in enumerate(sol)
        xs[i], ys[i] = pb.aero_to_coord[pt_idx, :]
    end
    plot!(xs, ys, color = :black,
                    lab="solution")
    title!("Solution, length=$(length(sol)), distance="*string(round(get_distance(pb, sol), digits=1)))
    gui()
end


function plot_sol(pb::Problem, edge_act)
    plot_sol(pb)

    for i=1:size(edge_act, 1), j=1:size(edge_act, 2)
        if edge_act[i, j] == 1
            xs = [pb.aero_to_coord[i, 1], pb.aero_to_coord[j, 1]]
            ys = [pb.aero_to_coord[i, 2], pb.aero_to_coord[j, 2]]
            plot!(xs, ys, color = :black)
        end
    end

    title!("Solution")
    gui()
end
