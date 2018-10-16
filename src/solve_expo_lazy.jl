export solve_expo_lazy


function solve_expo_lazy(pb)
    m = Model(solver=CplexSolver())

    m, xij = build_base_model(pb, model=m)

    function callback_wrapper(cb)
        printstyled("Setting callback\n", color=:red)
        xijs = getvalue(xij)

        cut_found, body, rhs = subtour(xijs, xij)

        if cut_found
            @lazyconstraint(cb, body <= rhs)
        end
    end

    addlazycallback(m, callback_wrapper)

    xsol = solve_model(m, pb, xij)

    return xsol
end



function subtour(xijs, xij)
    printstyled("In subtour fct\n", color=:red)


    arcs_to_treat = Set{Vector{Int}}()
    for (i, j) in keys(xijs)
        if xijs[i, j] == 1
            push!(arcs_to_treat, [i, j])
        end
    end

    @show arcs_to_treat

    complete_loops = Set{Set{Int}}()

    it = 0
    while length(arcs_to_treat) > 1 && it < 3

        printstyled("$arcs_to_treat\n", color=:green)
        
        # one iteration: work in place on arcs_to_treat...
        for arc in arcs_to_treat
            arc_updated = false

            i_start, i_end = arc[1], arc[end]

            ## Run through arcs_to_treat
            for potential_neighbor in setdiff(arcs_to_treat, arc) ## Poor efficiency
                # If arc can be pre or appended to potential_neighbor, do so

                new_arc = Int[]

                if i_start == potential_neighbor[end]
                    new_arc = vcat(potential_neighbor, arc[2:end])
                elseif i_end == potential_neighbor[1]
                    new_arc = vcat(arc[1:end-1], potential_neighbor)

                    delete!(arcs_to_treat, potential_neighbor)
                    push!(arcs_to_treat, new_arc)
                end

                # If new arc is a loop, add to complete loops and remove from arcs to treat
                if length(new_arc)>0 
                    if new_arc[1] == new_arc[end]
                        delete!(arcs_to_treat, potential_neighbor)
                        push!(complete_loops, Set{Int}(new_arc))
                    else
                        push!(arcs_to_treat, new_arc)
                    end

                    arc_updated = true
                end
            end

            # if arc could not be added to any potential neighbor, problem...
            if !arc_updated
                printstyled("   → Current arc $arc could not be updated;\n", color=:orange)
                printstyled("$arcs_to_treat\n", color=:orange)
            end
        end

        it = it + 1

    end

    # should be one arc remaining now, from start to end.
    @assert length(arcs_to_treat) == 1
    start_end_path = first(arcs_to_treat)

    @assert start_end_path[1] == pb.start_aero
    @assert start_end_path[end] == pb.end_aero


    ## Add loops constraints, return constraints.

    cut_found = true
    body = 1
    rhs = 2

    println()

    printstyled("Returning constraint\n$cut_found\n$body\n$rhs\n", color=:red)
    return cut_found, body, rhs
end






###################################################################
function subtour_old(cb)
  println("In subtour")
  cur_sol = getvalue(x)
  # println(cur_sol)

  # Find any subtour
  in_subtour = fill(false,n)
  cur_node = 1
  in_subtour[cur_node] = true
  subtour_length = 1
  while true
    # Find next unvisited node
    found_node = false
    for j = 1:n
      if !in_subtour[j]
        if cur_sol[cur_node,j] >= 0.9
          # Arc to unvisited node
          cur_node = j
          in_subtour[j] = true
          found_node = true
          subtour_length += 1
          break
        end
      end
    end
    if !found_node
      println("Done exploring")
      # Completely explored this subtour
      if subtour_length == n
        println("found tour!")
        # Done!
        break
      else
        # Add lazy constraint
        expr = AffExpr()
        for i = 1:n
          if !in_subtour[i]
            continue
          end
          # i is in S
          for j = 1:n
            if i == j
              continue
            end
            if in_subtour[j]
              # Both ends in subtour, bad
            else
              # j isn't in subtour
              expr += x[i,j]
            end
          end
        end
        println(expr)
        readline(stdin)
        @lazyconstraint(cb, expr >= 2)
        break
      end
    end
  end

end
