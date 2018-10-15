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

## TODOs

- [ ] Implement a non recursive way to compute set of all subsets, possibly with the iterator interface,
- [x] Model the 0 region, that does not have to be visited
- [x] Get number of variables and constraints from JuMP model
- [x] Implement model with a polynomial number of constraints
- [ ] Then look into column generation and relaxations...

- [ ] Lazy callback
- [x] Implement solve function
- [ ] Update polynomial model to new structure, test on all instances.
- [ ] Bound ui by n, for potential better relaxations.

### Example

```julia
]activate .
using SOD321Project; include("src/plot.jl")

pb = read_file("dummy_instance.txt")

xsol = 
```

### Evaluation

rapport:
- les deux modèles,
- par instance, donner l'optimum, les temps de calcul, le modèle choisi.

soutenance : test du code sur instances aléatoires.