# SOD321: Linear programming

Solving a plane mapping problem...

## Install

Works with julia v1.0.

Cloning the project and installing dependencies :
 - Clone the repo and enter the main folder,
 - launch julia,
 - `]activate .`,
 - `]instantiate`

Afterwards, for using the module or develop it, just run `]activate .` and `using SOD321Project`.

## list of functions

- `read_file(filepath::String)`: yields a `Problem` object describing the current instance,
- `plot_sol(pb::Problem)`: displays a map of the problem,
- `plot_sol(pb::Problem, sol::Vector{Int})`: displays a map of the problem and the given solution.

## Resolution

### Exponential constraints model

Initial 'dense' model is implemented in the `solve_expo` function.

Model 'sparse' in variables (only activation variables corresponding to edges that can be used) is implemented in the `solve_expo_sparse` function.

### Polynomial constraints model

Model 'sparse' in variables (only activation variables corresponding to edges that can be used) is implemented in the `solve_poly_sparse` function.

## TODOs:

- [ ] Implement a non recursive way to compute set of all subsets, possibly with the iterator interface,
- [ ] Model the 0 region, that does not have to be visited
- [ ] Get number of variables and constraints from JuMP model
- [ ] Implement model with a polynomial number of constraints
- [ ] Then look into column generation and relaxations...

### Example

```julia
]activate .
using SOD321Project

pb = read_file("dummy_instance.txt")
plot_sol(pb, [1, 3, 2, 5])
```
