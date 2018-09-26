export read_file, write_instance

function read_file(filepath::String)
    pb = Problem()
    open(filepath) do f
        n_aerodrome = parse(Int, readline(f))
        start_aero = parse(Int, readline(f))
        end_aero = parse(Int, readline(f))
        n_aero_parcour_min = parse(Int, readline(f))
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
                    n_aero_parcour_min)
    end

    return pb
end

function write_instance(pb, filepath::String)
    @assert ispath(first(splitdir(filepath)))

    isfile(filepath) && rm(filepath)
    touch(filepath)

    open(filepath, "w") do f
        println(f, pb.n_aerodrome)
        println(f, pb.start_aero)
        println(f, pb.end_aero)
        println(f, pb.n_aero_parcour_min)
        println(f, pb.n_regions)

        for (i, region) in enumerate(pb.aero_to_region)
            print(f, region, " ")
        end
        println(f)

        println(f, pb.airplane_range)

        for i=1:size(pb.aero_to_coord, 1)
            x, y = pb.aero_to_coord[i, :]
            println(f, x, " ", y)
        end
    end
end
