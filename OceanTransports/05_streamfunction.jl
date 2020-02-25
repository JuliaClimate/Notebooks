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
# # Decompose Transports into Streamfunction And Purely Divergent Component
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

# + {"slideshow": {"slide_type": "fragment"}, "cell_style": "split"}
using MeshArrays, Plots, Statistics, MITgcmTools
include("prepare_transports.jl")
if !isdir("../inputs/GRID_LLC90")
    run(`git clone https://github.com/gaelforget/GRID_LLC90 ../inputs/GRID_LLC90`)
end

# + {"slideshow": {"slide_type": "fragment"}, "cell_style": "split"}
mypath="../inputs/GRID_LLC90/"
mygrid=GridSpec("LatLonCap",mypath)
GridVariables=GridLoad(mygrid)
(TrspX, TrspY, TauX, TauY, SSH)=trsp_read(mygrid,mypath)
SPM,lon,lat=read_SPM(mypath)

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Transport Convergence And Land Mask
#
# _note: masking avoids isolated Canyons / singular matrices_

# + {"slideshow": {"slide_type": "fragment"}}
TrspCon=convergence(TrspX,TrspY)

msk=1.0 .+ 0.0 * mask(view(GridVariables["hFacC"],:,1),NaN,0.0)
TrspCon=msk*TrspCon;

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Helmholtz Decomposition
#
# 1. compute scalar potential
# 2. subtract divergent component
# 3. compute vector potential / streamfunction

# + {"slideshow": {"slide_type": "fragment"}}
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

# + {"slideshow": {"slide_type": "subslide"}, "cell_type": "markdown"}
# ### Verify The Results Consistency
#
# _TrspCon-tmpCon should be negligible compared with TrspCon_

# + {"slideshow": {"slide_type": "fragment"}}
tmpCon=convergence(TrspXdiv,TrspYdiv)
tmp1=TrspCon[3]
tmp2=tmp1[findall(isfinite.(tmp1))]
errCon=1/sqrt(mean(tmp2.^2)).*(tmpCon[3]-TrspCon[3])

heatmap(errCon)

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Map Out Streamfunction And Scalar Potential
#
# _Interpolation is used to readily create global maps_

# + {"slideshow": {"slide_type": "fragment"}, "cell_style": "split"}
TrspPsiI=MatrixInterp(write(1e-6*msk*TrspPsi),SPM,size(lon))
contourf(vec(lon[:,1]),vec(lat[1,:]),transpose(TrspPsiI),
    title="Streamfunction",clims=(-50,50))

# + {"slideshow": {"slide_type": "fragment"}, "cell_style": "split"}
TrspPotI=MatrixInterp(write(1e-6*msk*TrspPot),SPM,size(lon))
contourf(vec(lon[:,1]),vec(lat[1,:]),transpose(TrspPotI),
    title="Scalar Potential",clims=(-0.4,0.4))
# -


