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
#     display_name: Julia 1.6.2
#     language: julia
#     name: julia-1.6
# ---

# + [markdown] {"slideshow": {"slide_type": "slide"}}
# # Transport Streamfunction And Divergent Component
#
# Here we apply such [Helmholtz Decomposition](https://en.wikipedia.org/wiki/Helmholtz_decomposition) to vertically integrated transports defined over a Global Ocean model (`C-grid`).
#
# 1. read vertically integrated transport from file
# 2. compute its convergence and apply land mask
# 3. decompose into rotational and divergent components
# 4. derive streamfunction from the rotational component

# + [markdown] {"slideshow": {"slide_type": "slide"}}
# ### Read Transports & Grid From File
#
# 1. pre-requisites
# 2. read variables

# + {"slideshow": {"slide_type": "subslide"}, "cell_style": "center"}
using MeshArrays, Plots, Statistics
pth=dirname(pathof(MeshArrays))
include(joinpath(pth,"../examples/Plots.jl"))
include("helper_functions.jl")

pth=MeshArrays.GRID_LLC90
γ=GridSpec("LatLonCap",pth)
Γ=GridLoad(γ;option="full")
(Tx,Ty,τx,τy,η)=trsp_read("LatLonCap",pth);

# +
μ =Γ.hFacC[:,1]
μ[findall(μ.>0.0)].=1.0
μ[findall(μ.==0.0)].=NaN

lon=[i for i=-179.:2.0:179., j=-89.:2.0:89.]
lat=[j for i=-179.:2.0:179., j=-89.:2.0:89.]

#(f,i,j,w)=InterpolationFactors(Γ,vec(lon),vec(lat))
#λ=(lon=lon,lat=lat,f=f,i=i,j=j,w=w);
#df = DataFrame(f=λ.f[:], i=λ.i[:], j=λ.j[:], w=Float32.(λ.w[:]));
#CSV.write("interp_coeffs.csv", df)

df=DataFrame(CSV.File("interp_coeffs.csv"))
λ=(f=reshape(df.f,length(lon[:]),4), i=reshape(df.i,length(lon[:]),4),
    j=reshape(df.j,length(lon[:]),4), w=reshape(df.w,length(lon[:]),4));

# + [markdown] {"slideshow": {"slide_type": "slide"}}
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
TrspCon=μ.*convergence(Tx,Ty)

#scalar potential
TrspPot=ScalarPotential(TrspCon)

#Divergent transport component
(TxD,TyD)=gradient(TrspPot,Γ)
TxD=TxD.*Γ.DXC
TyD=TyD.*Γ.DYC

#Rotational transport component
TxR = Tx-TxD
TyR = Ty-TyD

#vector Potential
TrspPsi=VectorPotential(TxR,TyR,Γ);

# + [markdown] {"slideshow": {"slide_type": "skip"}}
# ### Verify The Results Consistency
#
# _Next plot below normally shows that TrspCon-tmpCon is negligible compared with TrspCon_

# + {"slideshow": {"slide_type": "skip"}, "cell_style": "center"}
tmpCon=convergence(TxD,TyD)
tmp1=TrspCon[3]
tmp2=tmp1[findall(isfinite.(tmp1))]
errCon=1/sqrt(mean(tmp2.^2)).*(tmpCon[3]-TrspCon[3])
errCon[findall(isnan.(errCon))].=0.0
extrema(errCon)

# + [markdown] {"slideshow": {"slide_type": "slide"}}
# ### Map Out Streamfunction And Scalar Potential
#
# _In plots below we interpolate MeshArrays to a regular global grid_

# + {"slideshow": {"slide_type": "subslide"}, "cell_style": "center"}
TrspPsiI=Interpolate(1e-6*μ*TrspPsi,λ.f,λ.i,λ.j,λ.w)
contourf(vec(lon[:,1]),vec(lat[1,:]),
    TrspPsiI,title="Streamfunction",clims=(-50,50))

# + {"slideshow": {"slide_type": "subslide"}, "cell_style": "center"}
TrspPotI=Interpolate(1e-6*μ*TrspPot,λ.f,λ.i,λ.j,λ.w)
contourf(vec(lon[:,1]),vec(lat[1,:]),
        TrspPotI,title="Scalar Potential",clims=(-0.4,0.4))
# -


