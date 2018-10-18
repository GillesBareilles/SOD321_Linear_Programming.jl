export solve_expo_lazy


function solve_expo_lazy(pb)
    m = Model(solver=CplexSolver())

    m, xij = build_base_model(pb, model=m)

    function callback_wrapper(cb)
        xijs = getvalue(xij)

        subtour(cb, xijs, xij)
    end

    addlazycallback(m, callback_wrapper)

    xsol = solve_model(m, pb, xij)


    arcs_to_treat = sol_to_arcs(getvalue(xij))

    loops, paths = get_loops_paths(arcs_to_treat)
    @show loops
    @show paths

    return xsol
end


"""
    subtour(cb, xijs, xij)

Build all lazy constraints invalid at given integer point `xijs`; `xij` is the dict of 
edge activation variables, used to build lazy constraints.
"""
function subtour(cb, xijs, xij)
    printLevel = 0

    printLevel>0 && printstyled("In subtour fct\n", color=:red)

    arcs_to_treat = sol_to_arcs(xijs)

    printLevel>0 && @show arcs_to_treat

    loops, paths = get_loops_paths(arcs_to_treat)
    printLevel>0 && @show loops
    printLevel>0 && @show paths

    ## Add loops constraints, return constraints.
    if length(loops) > 0 && length(paths) <= 1
        printLevel>0 && printstyled(" → Cuts to be added here:\n", color=:light_yellow)
        
        ## Exclude all loops
        for loop in loops
            expr = AffExpr()
            printLevel>0 && println("Dealing with loop $(loop)")
            for i=1:(length(loop)-1)
                expr += xij[loop[i], loop[i+1]]
            end
            expr += xij[loop[end], loop[1]]

            printLevel>0 && @show expr, length(loop)-1
            # readline(stdin)
            @lazyconstraint(cb, expr <= length(loop)-1)
        end
        
        ## Exclude paths (hopefully only one)
        for path in paths
            expr = AffExpr()
            printLevel>0 && println("Dealing with path $(path)")
            for i=1:(length(path)-1)
                expr += xij[path[i], path[i+1]]
            end

            printLevel>0 && @show expr, length(path)-2
            # readline(stdin)
            @lazyconstraint(cb, expr <= length(path)-2)
        end

    elseif length(loops) == 0 && length(paths) == 1
        printLevel>0 && printstyled(" → Valid solution here.\n", color=:green)
    else
        printLevel>0 && printstyled(" → Something strange here ......\n", color=:red)
    end

    nothing
end
