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
#     display_name: Julia 1.5.0
#     language: julia
#     name: julia-1.5
# ---

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# # Ocean Transports -- Integration And Mapping
#
# Transports in the climate system are often represented as gridded vector fields (e.g. on a `C-grid`) and integrated across `grid edge paths` that e.g. (1) connect location pairs or (2) tracks latitude circles. For more detail, please refer to [Forget et al, 2015](https://doi.org/10.5194/gmd-8-3071-2015) (incl. appendices)

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Read grid & transports from file
#
# 1. pre-requisites
# 2. read variables

# + {"slideshow": {"slide_type": "subslide"}}
using MeshArrays, Plots, Statistics
pth=dirname(pathof(MeshArrays))
include(joinpath(pth,"../examples/Plots.jl"))
include("helper_functions.jl")

pth=MeshArrays.GRID_LLC90
γ=GridSpec("LatLonCap",pth)
Γ=GridLoad(γ)
(Tx,Ty,τx,τy,η)=trsp_read("LatLonCap",pth);

# +
msk=1.0 .+ 0.0 * mask(view(Γ["hFacC"],:,1),NaN,0.0)

lon=[i for i=-179.5:1.0:179.5, j=-89.5:1.0:89.5]
lat=[j for i=-179.5:1.0:179.5, j=-89.5:1.0:89.5]
(f,i,j,w)=InterpolationFactors(Γ,vec(lon),vec(lat))
λ=Dict("f" => f,"i" => i,"j" => j,"w" => w);

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Integrate transport across latitude lines
#
# 1. `LatitudeCircles` computes `grid edge path`s that track latitude circles
# 2. `ThroughFlow` integrates transports accross the specified `grid edge path`s
# 3. Plot integrated meridional transport in `Sverdrup` units (1Sv=10^6 m³/s)

# + {"slideshow": {"slide_type": "subslide"}}
uv=Dict("U"=>Tx,"V"=>Ty,"dimensions"=>["x","y"])
L=-89.0:89.0; LC=LatitudeCircles(L,Γ)

T=Array{Float64,1}(undef,length(LC))
[T[i]=1e-6*ThroughFlow(uv,LC[i],Γ) for i=1:length(LC)]

plot(L,T,xlabel="latitude",ylabel="Northward Transport (in Sv)",label="ECCO estimate")

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## Transport Directions
#
# 1. `u,v` are oriented in the `Eastward,Northward` directions
# 2. `uC,vC` are oriented along the `x,y` directions of each subdomain

# + {"slideshow": {"slide_type": "-"}}
u,v,uC,vC=rotate_uv(uv,Γ);

# + {"slideshow": {"slide_type": "subslide"}, "cell_style": "split"}
heatmap(u,clims=(-20.0,20.0),title="East-ward")
#heatmap(v,clims=(-20.0,20.0),title="North-ward")

# + {"slideshow": {"slide_type": "fragment"}, "cell_style": "split"}
heatmap(uC,clims=(-20.0,20.0),title="x-ward")
#heatmap(vC,clims=(-20.0,20.0),title="y-ward")

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Global Maps
#
# 1. interpolate `u,v` to a `1/2 x 1/2` degree grid for plotting
# 2. map out the Eastward,Northward transport components

# + {"slideshow": {"slide_type": "-"}}
lon=[i for i=20.:2.0:380., j=-79.:2.0:89.]
lat=[j for i=20.:2.0:380., j=-79.:2.0:89.]
(f,i,j,w,_,_,_)=InterpolationFactors(Γ,vec(lon),vec(lat));
# -
uI=reshape(Interpolate(u,f,i,j,w),size(lon))
vI=reshape(Interpolate(v,f,i,j,w),size(lon))
size(lon)

# + {"slideshow": {"slide_type": "subslide"}, "cell_style": "split"}
heatmap(lon[:,1],lat[1,:],
    permutedims(uI),clims=(-20.0,20.0),
    title="Eastward transport (in Sv / cell)")
# + {"slideshow": {"slide_type": "fragment"}, "cell_style": "split"}
heatmap(lon[:,1],lat[1,:],
    permutedims(vI),clims=(-20.0,20.0),
    title="Northward transport (in Sv / cell)")
# -


