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
#     display_name: Julia 1.3.1
#     language: julia
#     name: julia-1.3
# ---

# ## `MeshArray`'s represent global gridded variables
#
# Each `MeshArray` contains an array of elementary arrays that (1) are connected at their edges and (2) collectively form a global grid. Global grid specifications are contained within `gcmgrid` instances.
#
# #### First, let's load the `MeshArrays` & `Plots` packages

# +
using MeshArrays, Plots

p=dirname(pathof(MeshArrays))
include(joinpath(p,"../examples/Plots.jl"))
# -

# #### Select a pre-defined grid such as `LLC90` grid commonly used with `MITgcm`

mygrid=GridSpec("LatLonCap","../inputs/GRID_LLC90/")

# And download the pre-defined grid if needed

if !isdir("../inputs/GRID_LLC90")
    run(`git clone https://github.com/gaelforget/GRID_LLC90 ../inputs/GRID_LLC90`)
end

# #### Read a MeshArray from file
#
# Read a global field from binary file and convert it to `MeshArrays`'s `gcmfaces` type

D=mygrid.read(mygrid.path*"Depth.data",MeshArray(mygrid,Float64))
show(D)

# Plot the subdomain arrays

heatmap(D,title="Ocean Depth",clims=(0.,6000.))


# The read / write functions can also be used to convert a MeshArray from / to Array

tmp1=write(D)
tmp2=read(tmp1,D)

# #### MeshArrays should behave just like Arrays
#
# Here are a few examples that would be coded similarly in both cases

# +
size(D)
eltype(D)
view(D,:)

D .* 1.0
D .* D
1000*D
D*1000

D[findall(D .> 300.)] .= NaN
D[findall(D .< 1.)] .= NaN

D[1]=0.0 .+ D[1]
tmp=cos.(D)
# -

