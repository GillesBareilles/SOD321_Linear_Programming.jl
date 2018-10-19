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

### Stats

All runs are executed over salle.ensta.fr ; 32 CPUs at 1.995 GHz

#### Problems description

Problem       | dummy | aero_1 | aero_2 | aero_4 | aero_5
:-----------: | :--: | :--: | :--: | :--: | :--:
n_aero        | 6       | 50    | 70    | 40    | 30
n_regions     | 2       | 4     | 16    | 2     |  3
final objective | 12    | 168   | 235   | 114   | 130

#### Lazy model

Problem       | dummy | aero_1 | aero_2 | aero_4 | aero_5
:-----------: | :--: | :--: | :--: | :--: | :--:
n_variables   | 18      | 420   | 688   | 398   | 144
nb init ctr   | 18      | 154   | 237   | 119   | 92
total time    | 18 s    | 18s   | 5.8s  | 2.6   | 4.0
nb nodes      | 0       | 25000 | 3500  | 3500  | 10400
nb cuts added | 2       | 880   | 487   | 223   | 324


#### Polynomial model

Parallelized over 32 CPUs

Problem       | dummy   | aero_1 | aero_2 | aero_4 | aero_5
:-----------: | :-----: | :----: | :----: | :----: | :--:
n_variables   | 24      | 470    | 758    | 438    | 174
nb ctr        | 36      | 574    | 925    | 517    | 236
total time    | 0.2s    | 9.8s   | 154s   | 1.3s   | 4.1
nb nodes      | 0       | 67000  | 1.1e6  | 6300   | 10300

#### Constraint generation over exponential model

Master and subproblems are solved sequnetially, each parallelized over 32CPUs.

Problem             | dummy | aero_1 | aero_2 | aero_4 | aero_5
:-----------------: | :--: | :--: | :--: | :--: | :--:
n_variables         | 
nb init ctr         | 
nb of master solves | 
nb ctrs generated   | 

total time          | 
nb nodes            | 
