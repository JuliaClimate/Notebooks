# ---
# jupyter:
#   jupytext:
#     formats: ipynb,jl:light
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.4'
#       jupytext_version: 1.2.1
#   kernelspec:
#     display_name: Julia 1.1.0
#     language: julia
#     name: julia-1.1
# ---

# ## `MeshArrays.jl` test suite uses a global smoother function

# Load the `MeshArrays.jl` and `Plots.jl` package modules

using MeshArrays, Plots

# Define a grid with `6` faces of `16*16` points and distances, areas, etc. all set to `1.0`:

GridVariables=GridOfOnes("cs",6,16);

# Smooth a field of random noise defined over the 6 faces of a cube:

DemoVariables=MeshArrays.demo2(GridVariables);

# Include `heatmap` method and use it to vizualize the final result:

include(joinpath(dirname(pathof(MeshArrays)),"Plots.jl"))
heatmap(DemoVariables[2],title="smoothed noise",clims=(-1.0,1.0))

# Note the increased smoothness and reduced magnitude as compared with the initial condition:

heatmap(DemoVariables[1],title="initial noise",clims=(-1.0,1.0))

# To finish, let's benchmark `smooth` as a function of smoothing scale parameters:

Rini=DemoVariables[1]
DXCsm=DemoVariables[3]
DYCsm=DemoVariables[4]
@time Rend=smooth(Rini,DXCsm,DYCsm,GridVariables);
@time Rend=smooth(Rini,2DXCsm,2DYCsm,GridVariables);


