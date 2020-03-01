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
# ### Read Model Grid & Transports From File
#
# 1. pre-requisites
# 2. read variables

# +
#]add MITgcmTools#gfdev01

# + {"slideshow": {"slide_type": "-"}, "cell_style": "center"}
using MeshArrays, Plots, Statistics, MITgcmTools
include("helper_functions.jl")
get_grid_if_needed()

γ=GridLoad(GridSpec("LatLonCap","../inputs/GRID_LLC90/"))
(Tx,Ty,τx,τy,η)=trsp_read("LatLonCap","../inputs/GRID_LLC90/")
SPM,lon,lat=read_SPM("../inputs/GRID_LLC90/")
msk=1.0 .+ 0.0 * mask(view(γ["hFacC"],:,1),NaN,0.0);

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
TrspCon=msk.*convergence(Tx,Ty);

#scalar potential
TrspPot=ScalarPotential(TrspCon)

#Divergent transport component
(TxD,TyD)=gradient(TrspPot,γ)
TxD=TxD.*γ["DXC"]
TyD=TyD.*γ["DYC"]

#Rotational transport component
TxR = Tx-TyD
TyR = Ty-TyD

#vector Potential
TrspPsi=VectorPotential(TxR,TyR,γ);

# + {"slideshow": {"slide_type": "subslide"}, "cell_type": "markdown"}
# ### Verify The Results Consistency
#
# _TrspCon-tmpCon should be negligible compared with TrspCon_

# + {"slideshow": {"slide_type": "-"}}
tmpCon=convergence(TxD,TyD)
tmp1=TrspCon[3]
tmp2=tmp1[findall(isfinite.(tmp1))]
errCon=1/sqrt(mean(tmp2.^2)).*(tmpCon[3]-TrspCon[3])
heatmap(errCon)

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Map Out Streamfunction And Scalar Potential
#
# _Interpolation is used to create global maps_

# + {"slideshow": {"slide_type": "-"}, "cell_style": "split"}
TrspPsiI=MatrixInterp(write(1e-6*msk*TrspPsi),SPM,size(lon))
contourf(vec(lon[:,1]),vec(lat[1,:]),transpose(TrspPsiI),
    title="Streamfunction",clims=(-50,50))

# + {"slideshow": {"slide_type": "-"}, "cell_style": "split"}
TrspPotI=MatrixInterp(write(1e-6*msk*TrspPot),SPM,size(lon))
contourf(vec(lon[:,1]),vec(lat[1,:]),transpose(TrspPotI),
    title="Scalar Potential",clims=(-0.4,0.4))
# -


