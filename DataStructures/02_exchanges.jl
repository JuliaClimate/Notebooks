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

# ## Data exchange between neighbor arrays
#
# The implementation of `exchange` functions is a central concept of `MeshArrays.jl` illustrated here through a basic example. It is further used in `03_smoothing.ipynb` that applies diffusion over the surface of a sphere.
#
# #### First, Let's load the `MeshArrays.jl` and `Plots.jl` package modules

using MeshArrays, Plots

# Download the pre-defined grid if needed

if !isdir("../inputs/GRID_CS32") 
    run(`git clone https://github.com/gaelforget/GRID_CS32 ../inputs/GRID_CS32`)
end

# Select `cube sphere` grid and read `ocean depth` variable

mygrid=GridSpec("CubeSphere","../inputs/GRID_CS32/")
D=mygrid.read(mygrid.path*"Depth.data",MeshArray(mygrid,Float32))
show(D)

# #### Use the `exchange` function
#
# It will add neighboring points at face edges as seen below

Dexch=exchange(D,4)
show(Dexch)

# We can also illustrate what happened using `Plots.jl`

P=heatmap(D.f[6],title="Ocean Depth (D, Face 6)",lims=(-4,36))
Pexch=heatmap(Dexch.f[6],title="...(Dexch, Face 6)",lims=(0,40))
plot(P,Pexch)


