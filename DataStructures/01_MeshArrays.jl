# -*- coding: utf-8 -*-
# ---
# jupyter:
#   jupytext:
#     cell_metadata_json: true
#     formats: ipynb,jl:light
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.11.3
#   kernelspec:
#     display_name: Julia 1.7.0-beta3
#     language: julia
#     name: julia-1.7
# ---

# + [markdown] {"slideshow": {"slide_type": "slide"}}
# # Gridded Domains Using `MeshArrays.jl`
#
# A `MeshArray` contains an array of subdomain arrays that (1) are connected at their edges and (2) collectively form a global grid. Grid specifications are contained in `gcmgrid` data structures. These merely define array sizes and how e.g. grid variables are represented in memory -- it is only when variables are read from file that larger memory allocations occur.

# + [markdown] {"slideshow": {"slide_type": "slide"}}
# ## Grid Configuration
#
# 1. import `MeshArrays` and plotting tools
# 2. choose e.g. a standard `MITgcm` grid

# + {"cell_style": "center", "slideshow": {"slide_type": "subslide"}}
using MeshArrays, Plots

pth=MeshArrays.GRID_LLC90
γ=GridSpec("LatLonCap",pth);
#Γ=GridLoad(γ)

# + [markdown] {"slideshow": {"slide_type": "slide"}}
# ## Read Example
#
# A `MeshArray` variable, on the chosen grid, can be accessed from file via `γ.read`(argument #1). Format conversion occurs inside the `read` function based on a propotype (argument #2). Further `read` / `write` calls convert back and forth between `MeshArray` and `Array` formats if needed.

# + {"slideshow": {"slide_type": "subslide"}}
D=γ.read(γ.path*"Depth.data",MeshArray(γ,Float64))
tmp1=write(D); tmp2=read(tmp1,D)
show(D)

# + [markdown] {"slideshow": {"slide_type": "slide"}}
# ## Subdomain Arrays
#
# The heatmap method is specialized for `MeshArray`s below. It operates on each `inner-array` sequentially, one after the other.

# + {"slideshow": {"slide_type": "subslide"}}
import Plots: heatmap

function heatmap(x::MeshArray; args...)
    n=x.grid.nFaces
    p=()
    for i=1:n; p=(p...,heatmap(x[i]; args...)); end
    plot(p...)
end

heatmap(D,title="Ocean Depth",clims=(0.,6000.))


# + [markdown] {"slideshow": {"slide_type": "slide"}}
# ## `MeshArray` Behaves Like `Array`
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
tmp=cos.(D);
# + [markdown] {"slideshow": {"slide_type": "slide"}}
# ## Try Another Grid
#
# The `cube-sphere` grid in `MeshArrays.GRID_CS32` has 6 subdomains, each of size `32x32`.
# -

pth=MeshArrays.GRID_CS32
γ=GridSpec("CubeSphere",pth)
D=γ.read(γ.path*"Depth.data",MeshArray(γ,Float32))
show(D)

# + [markdown] {"slideshow": {"slide_type": "slide"}}
# ## The `exchange` Function
#
# This function adds neighboring data points (columns or rows) at face edges to slightly extend the computational domain. Doing this is often needed e.g. to compute partial derivatives between subdomains of the climate system.
# -

Dexch=exchange(D,4)
show(Dexch)

# Here is a visualization for subdomain `#6`:

# + {"slideshow": {"slide_type": "subslide"}}
P=heatmap(D.f[6],title="Ocean Depth (D, Face 6)",lims=(-4,36))
Pexch=heatmap(Dexch.f[6],title="...(Dexch, Face 6)",lims=(0,40))
plot(P,Pexch)

# + [markdown] {"slideshow": {"slide_type": "slide"}}
# # Global Diffusion Example
#
# Regular testing of `MeshArrays.jl` uses the `smooth()` function as an example. Starting from a random noise field, diffusive smoothing efficiency is predictable and can be set via a scale parameter [(see Weaver and Courtier, 2001)](https://doi.org/10.1002/qj.49712757518).
#
# This example also illustrates the generality of the approach chosen in `MeshArrays.jl`, where the same code (see `demo2`) is pretty much readily applicable to any `PeriodicDomain`, `PeriodicChannel`, `CubeSphere`, or `LatLonCap` grid. Here the chosen grid crudely represents the Earth as a unit-cube with `16*16` points on each of the 6 faces. Grid cell areas and distances are all artificially set to `1.0` for simplicity.

# + {"slideshow": {"slide_type": "subslide"}}
pth=dirname(pathof(MeshArrays))
include(joinpath(pth,"../examples/Demos.jl"))
γ,Γ=GridOfOnes("CubeSphere",6,16)
Δ=demo2(Γ);

# + [markdown] {"slideshow": {"slide_type": "subslide"}}
# The initial noise field is `D[1]` while the smoothed one is `D[2]`. After `smooth()` has been applied via `demo2()`, the noise field is visibly smoother and more muted.

# + {"cell_style": "split"}
heatmap(Δ[1],title="initial noise",clims=(-0.5,0.5))

# + {"cell_style": "split"}
heatmap(Δ[2],title="smoothed noise",clims=(-0.5,0.5))

# + [markdown] {"slideshow": {"slide_type": "subslide"}}
# The computational cost of `smooth()` predictably  increases with the decorrelation scale. For more about how this works, please refer to **Weaver and Courtier, 2001** _Correlation modelling on the sphere using a generalized diffusion equation_ https://doi.org/10.1002/qj.49712757518
# -

Rini=Δ[1]
DXCsm=Δ[3]
DYCsm=Δ[4]
@time Rend=smooth(Rini,DXCsm,DYCsm,Γ);
@time Rend=smooth(Rini,2DXCsm,2DYCsm,Γ);
