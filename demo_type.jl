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

# ## `MeshArrays.jl` represents global grids where multiple arrays are connected at their edges as a new data type
#
# Load the `MeshArrays.jl` package

using MeshArrays

# Select a pre-defined grid; `LLC90` is used here

mygrid=GridSpec("LLC90")

# Download the pre-defined grid if needed

if !isdir("GRID_LLC90") 
    run(`git clone https://github.com/gaelforget/GRID_LLC90`)
end

# Read a global field from binary file and convert it to `MeshArrays`'s `gcmfaces` type

D=mygrid.read(mygrid.path*"Depth.data",MeshArray(mygrid,Float64))
show(D)


