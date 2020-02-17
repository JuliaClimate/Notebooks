# ---
# jupyter:
#   jupytext:
#     formats: ipynb,jl:light
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.4'
#       jupytext_version: 1.2.4
#   kernelspec:
#     display_name: Julia 1.2.0
#     language: julia
#     name: julia-1.2
# ---

# # Spatial diffusion / smoothing example
#
# The unit testing of `MeshArrays.jl` uses the `smooth()` function. Its effect on a random noise field is to smooth it down. The average smoother efficiency is predictable and can be set via a `scale parameter`. The method as defined inside `demo2` is applicable for any `PeriodicDomain`, `PeriodicChanel`, `CubeSphere`, or `LatLon-Gap` Earth grid.
#
# For more about the diffusion-based smoother, please refer to [Weaver and Courtier, 2001](https://doi.org/10.1002/qj.49712757518) Correlation modelling on the sphere using a generalized diffusion equation.

# #### Load  `MeshArrays` and `Plots`  modules

# +
using MeshArrays, Plots

p=dirname(pathof(MeshArrays))
include(joinpath(p,"../examples/Plots.jl"))
include(joinpath(p,"../examples/Demos.jl"))
# -

# Grid the `6` faces of a cube with `16*16` points on each face. Distances, areas, etc. are all set to `1.0` for simplicity.

GridVariables=GridOfOnes("CubeSphere",6,16);

# #### Diffuse a noisy field over the surface of a cube

DemoVariables=demo2(GridVariables);

# #### Display the 6 cube faces using  `heatmap`
#
# The orignal noise field is `DemoVariables[1]` while the smoothed one
# is `DemoVariables[2]`.

heatmap(DemoVariables[1],title="initial noise",clims=(-0.5,0.5))

# After `smooth()` has been applied via `demo2()`, the noise is smoother and muted.

heatmap(DemoVariables[2],title="smoothed noise",clims=(-0.5,0.5))

# The cost of applying `smooth()` predictably  increases with the decorrelation scale. For more about how this works, please refer to **Weaver and Courtier, 2001.** Correlation modelling on the sphere using a generalized diffusion equation. https://doi.org/10.1002/qj.49712757518

Rini=DemoVariables[1]
DXCsm=DemoVariables[3]
DYCsm=DemoVariables[4]
@time Rend=smooth(Rini,DXCsm,DYCsm,GridVariables);
@time Rend=smooth(Rini,2DXCsm,2DYCsm,GridVariables);


