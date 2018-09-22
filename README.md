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

### Example

```julia
]activate .
using SOD321Project

pb = read_file("dummy_instance.txt")
plot_sol(pb, [1, 3, 2, 5])
```
