export solve_expo_lazy


function solve_expo_lazy(pb)
    m = Model(solver=CplexSolver())

    m, xij = build_base_model(pb, model=m)

    add_lazy_callback!(pb, m, xij)


    returnsolved = solve(m)

    # println(getvalue(x))
    # println(returnsolved)
    # println(getobjectivevalue(m))


    return m, xij
end

"""
    add_lazy_callback!(m, pb, xij)

set callback for dynamically adding lazy cuts.
"""
function add_lazy_callback!(m, pb, xij)
    printstyled("yet to be done, cf tsp.jl\n", color=:green)
end



function subtour(cb)
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
