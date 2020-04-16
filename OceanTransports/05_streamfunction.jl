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
# # Transport Streamfunction And Divergent Component
#
# Here we apply such [Helmholtz Decomposition](https://en.wikipedia.org/wiki/Helmholtz_decomposition) to vertically integrated transports defined over a Global Ocean model (`C-grid`).
#
# 1. read vertically integrated transport from file
# 2. compute its convergence and apply land mask
# 3. decompose into rotational and divergent components
# 4. derive streamfunction from the rotational component

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Read Transports & Grid From File
#
# 1. pre-requisites
# 2. read variables

# + {"slideshow": {"slide_type": "skip"}}
#]add MITgcmTools#master

# + {"slideshow": {"slide_type": "subslide"}, "cell_style": "center"}
using MeshArrays, Plots, Statistics
include("helper_functions.jl")
get_grid_if_needed()

Γ=GridLoad(GridSpec("LatLonCap","../inputs/GRID_LLC90/"))
(Tx,Ty,τx,τy,η)=trsp_read("LatLonCap","../inputs/GRID_LLC90/")
msk=1.0 .+ 0.0 * mask(view(Γ["hFacC"],:,1),NaN,0.0)

lon=[i for i=-179.5:1.0:179.5, j=-89.5:1.0:89.5]
lat=[j for i=-179.5:1.0:179.5, j=-89.5:1.0:89.5]
(f,i,j,w)=InterpolationFactors(Γ,vec(lon),vec(lat))
λ=Dict("f" => f,"i" => i,"j" => j,"w" => w);

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Helmholtz Decomposition
#
# 1. convergence & land mask
# 2. compute scalar potential
# 3. subtract divergent component
# 4. compute vector potential / streamfunction
#
# _note: masking avoids singularities related to isolated canyons_

# + {"slideshow": {"slide_type": "subslide"}}
#convergence & land mask
TrspCon=msk.*convergence(Tx,Ty)

#scalar potential
TrspPot=ScalarPotential(TrspCon)

#Divergent transport component
(TxD,TyD)=gradient(TrspPot,Γ)
TxD=TxD.*Γ["DXC"]
TyD=TyD.*Γ["DYC"]

#Rotational transport component
TxR = Tx-TyD
TyR = Ty-TyD

#vector Potential
TrspPsi=VectorPotential(TxR,TyR,Γ);

# + {"slideshow": {"slide_type": "skip"}, "cell_type": "markdown"}
# ### Verify The Results Consistency
#
# _Next plot below normally shows that TrspCon-tmpCon is negligible compared with TrspCon_

# + {"slideshow": {"slide_type": "skip"}, "cell_style": "split"}
tmpCon=convergence(TxD,TyD)
tmp1=TrspCon[3]
tmp2=tmp1[findall(isfinite.(tmp1))]
errCon=1/sqrt(mean(tmp2.^2)).*(tmpCon[3]-TrspCon[3])
heatmap(errCon)

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Map Out Streamfunction And Scalar Potential
#
# _In plots below we interpolate MeshArrays to a regular global grid_

# + {"slideshow": {"slide_type": "subslide"}, "cell_style": "center"}
TrspPsiI=Interpolate(1e-6*msk*TrspPsi,λ["f"],λ["i"],λ["j"],λ["w"])
contourf(vec(lon[:,1]),vec(lat[1,:]),TrspPsiI,title="Streamfunction",clims=(-50,50))

# + {"slideshow": {"slide_type": "subslide"}, "cell_style": "center"}
TrspPotI=Interpolate(1e-6*msk*TrspPot,λ["f"],λ["i"],λ["j"],λ["w"])
contourf(vec(lon[:,1]),vec(lat[1,:]),TrspPotI,title="Scalar Potential",clims=(-0.4,0.4))
# -


