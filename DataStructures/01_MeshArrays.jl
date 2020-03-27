# -*- coding: utf-8 -*-
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

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# # `MeshArrays.jl` defines the `MeshArray` type
#
# Each `MeshArray` contains an array of elementary arrays that (1) are connected at their edges and (2) collectively form a global grid. Overall grid specifications are contained within `gcmgrid` instances, which merely define array sizes and how e.g. grid variables are represented in memory. Importantly, it is only when e.g. grid variables are read from file that sizable memory is allocated.

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## Initialize Framework
#
# 1. import `MeshArrays` and plotting tools
# 2. choose e.g. a standard `MITgcm` grid
# 3. download the grid if needed
#

# + {"cell_style": "center", "slideshow": {"slide_type": "subslide"}}
using MeshArrays, Plots

pth="../inputs/GRID_LLC90/"
γ=GridSpec("LatLonCap",pth)

http="https://github.com/gaelforget/GRID_LLC90"
!isdir(pth) ? run(`git clone $http $pth`) : nothing;

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## Read Example
#
# A `MeshArray` instance, on the chosen grid, can be obtained from a file path (argument #1). Format conversion occur inside the `read` function based on a propotype argument (#2). `read` / `write` calls then convert back and forth between `MeshArray` and `Array` formats.

# + {"slideshow": {"slide_type": "subslide"}}
D=γ.read(γ.path*"Depth.data",MeshArray(γ,Float64))
tmp1=write(D); tmp2=read(tmp1,D)
show(D)

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## Subdomain Arrays
#
# The heatmap function as specialized in `../examples/Plots.jl` operates on each `inner-array` sequentially, one after the other.

# + {"slideshow": {"slide_type": "subslide"}}
p=dirname(pathof(MeshArrays))
include(joinpath(p,"../examples/Plots.jl"))
heatmap(D,title="Ocean Depth",clims=(0.,6000.))


# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## A `MeshArray` Behaves Like A `Array`
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
# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## Let's switch grid now

# +
pth="../inputs/GRID_CS32/"
γ=GridSpec("LatLonCap",pth)

http="https://github.com/gaelforget/GRID_CS32"
!isdir(pth) ? run(`git clone $http $pth`) : nothing

γ=GridSpec("CubeSphere",pth)
D=γ.read(γ.path*"Depth.data",MeshArray(γ,Float32))
show(D)

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## The `exchange` Function
#
# It adds neighboring points at face edges to slightly extend the computational domain as often needed e.g. to compute partial derivatives.
# -

Dexch=exchange(D,4)
show(Dexch)

# + {"slideshow": {"slide_type": "subslide"}}
P=heatmap(D.f[6],title="Ocean Depth (D, Face 6)",lims=(-4,36))
Pexch=heatmap(Dexch.f[6],title="...(Dexch, Face 6)",lims=(0,40))
plot(P,Pexch)

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# # Diffusion-Based Smoothing
#
# The unit testing of `MeshArrays.jl` uses the `smooth()` function. Starting from a random noise field, the smoothing efficiency is predictable and can be set via a smoothing scale parameter [(see Weaver and Courtier, 2001)](https://doi.org/10.1002/qj.49712757518).
#
# This example also illustrates the generality of the `MeshArrays` approach, where the same code in `demo2` is readily applicable to any `PeriodicDomain`, `PeriodicChannel`, `CubeSphere`, or `LatLonCap` grid. Here the chosen grid maps onto the `6` faces of a cube with `16*16` points per face, with distances, areas, etc all set to `1.0`.

# + {"slideshow": {"slide_type": "subslide"}}
p=dirname(pathof(MeshArrays))
include(joinpath(p,"../examples/Demos.jl"))
γ,Γ=GridOfOnes("CubeSphere",6,16)
Δ=demo2(Γ);

# + {"slideshow": {"slide_type": "subslide"}, "cell_type": "markdown"}
# The initial noise field is `D[1]` while the smoothed one is `D[2]`. After `smooth()` has been applied via `demo2()`, the noise field is visibly smoother and more muted.

# + {"cell_style": "split"}
heatmap(Δ[1],title="initial noise",clims=(-0.5,0.5))

# + {"cell_style": "split"}
heatmap(Δ[2],title="smoothed noise",clims=(-0.5,0.5))

# + {"slideshow": {"slide_type": "subslide"}, "cell_type": "markdown"}
# The computational cost of `smooth()` predictably  increases with the decorrelation scale. For more about how this works, please refer to **Weaver and Courtier, 2001** _Correlation modelling on the sphere using a generalized diffusion equation_ https://doi.org/10.1002/qj.49712757518
# -

Rini=Δ[1]
DXCsm=Δ[3]
DYCsm=Δ[4]
@time Rend=smooth(Rini,DXCsm,DYCsm,Γ);
@time Rend=smooth(Rini,2DXCsm,2DYCsm,Γ);
