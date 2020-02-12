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
#     display_name: Julia 1.1.0
#     language: julia
#     name: julia-1.1
# ---

# # Transport Streamfunction And Divergence
#
# This notebook proceeds in several steps:
#
# - read vertically integrated transport vector field from file
# - compute its convergence and apply land mask
# - **Helmholtz Decomposition** : split into rotational and divergent components
# - compute streamfunction from the non-divergent component
#
# ### Time average and vertically integrate transports
#
# _note: `trsp_read` reloads intermediate results from file._

# +
using MeshArrays, Plots, Statistics, MITgcmTools

include("prepare_transports.jl")

if !isdir("../inputs/GRID_LLC90")
    run(`git clone https://github.com/gaelforget/GRID_LLC90 ../inputs/GRID_LLC90`)
end

mypath="../inputs/GRID_LLC90/"
mygrid=GridSpec("LatLonCap",mypath)

GridVariables=GridLoad(mygrid)
SPM,lon,lat=read_SPM(mypath)
(TrspX, TrspY, TauX, TauY, SSH)=trsp_read(mygrid,mypath);
# -

# ### Compute convergence and apply land mask
#
# _note: masking avoids isolated Canyons / singular matrices_

# +
TrspCon=convergence(TrspX,TrspY);

msk=1.0 .+ 0.0 * mask(view(GridVariables["hFacC"],:,1),NaN,0.0)

TrspCon=msk*TrspCon;
# -

# ### Helmholtz Decomposition
#
# The basic steps are:
# - compute scalar potential
# - subtract divergent component
# - compute vector potential / streamfunction

# +
#scalar potential
TrspPot=ScalarPotential(TrspCon)

#Divergent transport component
(TrspXdiv,TrspYdiv)=gradient(TrspPot,GridVariables)
TrspXdiv=TrspXdiv.*GridVariables["DXC"]
TrspYdiv=TrspYdiv.*GridVariables["DYC"]

#Rotational transport component
TrspXrot = TrspX-TrspXdiv
TrspYrot = TrspY-TrspYdiv

#vector Potential
TrspPsi=VectorPotential(TrspX,TrspY,GridVariables);
# -

# ### Check that convergent terms match
#
# _TrspCon-tmpCon should be negligible compared with TrspCon_

# +
tmpCon=convergence(TrspXdiv,TrspYdiv)
tmp1=TrspCon[3]
tmp2=tmp1[findall(isfinite.(tmp1))]
errCon=1/sqrt(mean(tmp2.^2)).*(tmpCon[3]-TrspCon[3])

heatmap(errCon)
# -

# ### Streamfunction And Scalar Potential Maps

TrspPsiI=MatrixInterp(write(1e-6*msk*TrspPsi),SPM,size(lon))
contourf(vec(lon[:,1]),vec(lat[1,:]),transpose(TrspPsiI),
    title="Streamfunction",clims=(-50,50))

TrspPotI=MatrixInterp(write(1e-6*msk*TrspPot),SPM,size(lon))
contourf(vec(lon[:,1]),vec(lat[1,:]),transpose(TrspPotI),
    title="Scalar Potential",clims=(-0.4,0.4))


