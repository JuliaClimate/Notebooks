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

# # Ocean transports and flow maps
#
# Global, northward transport of seawater is here integrated over the Global Ocean from three-dimensional, time-varying velocity fields.
#
# **key functions:** 
# - `LatitudeCircles` computes integration paths that follow latitude circles
# - `ThroughFlow` computes transports through these integration paths

# ### Time mean, vertically integrated transports
#
# This step has been done earlier for you and results saved to a few smaller files. 
#
# Let's re-read those using `trsp_read` from `prepare_transports.jl`.

# +
using MeshArrays
include("prepare_transports.jl")

if !isdir("GRID_LLC90") 
    run(`git clone https://github.com/gaelforget/GRID_LLC90`)
end
mygrid=GridSpec("LLC90");
GridVariables=GridLoad(mygrid);

(TrspX, TrspY, TauX, TauY, SSH)=trsp_read(mygrid,"GRID_LLC90/");

#using Statistics
#using FortranFiles
#!isdir("nctiles_climatology") ? error("missing files") : nothing
#include(joinpath(dirname(pathof(MeshArrays)),"gcmfaces_nctiles.jl"))
#(TrspX, TrspY, TauX, TauY, SSH)=trsp_prep(mygrid,GridVariables,"GRID_LLC90/");
# -

# ### Transport integrals across parallels

# +
UVmean=Dict("U"=>TrspX,"V"=>TrspY,"dimensions"=>["x","y"]);
LC=LatitudeCircles(-89.0:89.0,GridVariables);

T=Array{Float64,1}(undef,length(LC));
for i=1:length(LC)
   T[i]=ThroughFlow(UVmean,LC[i],GridVariables)
end
# -

# Plot result:

using Plots
lat=-89.0:89.0
plot(lat,T/1e6,xlabel="latitude",ylabel="Sverdrup (10^6 m^3 s^-1)",
    label="ECCOv4r2",title="Northward transport of seawater (Global Ocean)")

# Plot transport vector component Maps. 
#
# _Note that vector field orientations differ amongst the arrays._

include(joinpath(dirname(pathof(MeshArrays)),"Plots.jl"))
heatmap(1e-6*TrspX,clims=(-20.0,20.0))
#heatmap(1e-6*TrspY,clims=(-20.0,20.0))

# Convert to `Sv` and mask out land

u=1e-6 .*UVmean["U"]; v=1e-6 .*UVmean["V"];
u[findall(GridVariables["hFacW"][:,1].==0)].=NaN;
v[findall(GridVariables["hFacS"][:,1].==0)].=NaN;

# `x/y` transport at cell center

# +
using Statistics
nanmean(x) = mean(filter(!isnan,x))
nanmean(x,y) = mapslices(nanmean,x,dims=y)

(u,v)=exch_UV(u,v);
uC=similar(u); vC=similar(v);
for iF=1:mygrid.nFaces;
    tmp1=u[iF][1:end-1,:]; tmp2=u[iF][2:end,:];
    uC[iF]=reshape(nanmean([tmp1[:] tmp2[:]],2),size(tmp1));
    tmp1=v[iF][:,1:end-1]; tmp2=v[iF][:,2:end];
    vC[iF]=reshape(nanmean([tmp1[:] tmp2[:]],2),size(tmp1));
end
# -

# `Eastward/Northward` transport
#
# _Compare vector field orientations with the previous case._

cs=GridVariables["AngleCS"];
sn=GridVariables["AngleSN"];
u=uC.*cs-vC.*sn;
v=uC.*sn+vC.*cs;
heatmap(u,clims=(-20.0,20.0))

# Transport as a function of longitude and latitude

# +
cbp="https://github.com/gaelforget/CbiomesProcessing.jl"
using Pkg; Pkg.add(PackageSpec(url=cbp))
using CbiomesProcessing

SPM,lon,lat=CbiomesProcessing.read_SPM("GRID_LLC90/")
uI=CbiomesProcessing.MatrixInterp(write(u),SPM,size(lon))
heatmap(vec(lon[:,1]),vec(lat[1,:]),transpose(uI))
# -

