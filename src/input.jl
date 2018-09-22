export read_file

function read_file(filepath::String)
    pb = Problem()
    open(filepath) do f
        n_aerodrome = parse(Int, readline(f))
        start_aero = parse(Int, readline(f))
        end_aero = parse(Int, readline(f))
        n_aero_parcour = parse(Int, readline(f))
        n_regions = parse(Int, readline(f))

        aero_to_region = parse.(Int, split(readline(f)))

        airplane_range = parse(Int, readline(f))

        aero_to_coord = zeros(Int, n_aerodrome, 2)

        i = 1
        while !eof(f)
            aero_to_coord[i, :] = parse.(Int, split(readline(f)))
            i += 1
        end
        @assert i == n_aerodrome+1

        pb = Problem(n_aerodrome,
                    n_regions,
                    aero_to_region,
                    aero_to_coord,
                    airplane_range,
                    start_aero,
                    end_aero,
                    n_aero_parcour)
    end

    return pb
end
