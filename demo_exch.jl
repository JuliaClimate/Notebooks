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

# ## A key concept in `MeshArrays.jl` is the exchange of data between neighboring arrays
#
# Load the `MeshArrays.jl` and `'Plots.jl` package modules

using MeshArrays, Plots

# Download the pre-defined grid if needed

if !isdir("GRID_CS32") 
    run(`git clone https://github.com/gaelforget/GRID_CS32`)
end

# Select `cube sphere` grid and read `ocean depth` variable

mygrid=GCMGridSpec("CS32")
D=mygrid.read(mygrid.path*"Depth.data",gcmfaces(mygrid,Float32))
show(D)

# Use the `exchange` function to add neighboring points at face edges

Dexch=exchange(D,4)
show(Dexch)

# Illustrate what happened using `Plots.jl`

P=heatmap(D.f[6],title="Ocean Depth (D, Face 6)")
Pexch=heatmap(Dexch.f[6],title="...(Dexch, Face 6)")
plot(P,Pexch)


