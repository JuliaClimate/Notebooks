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

# # Ocean transport functions
#
# Computation of northward ("meridional") transport of seawater integrated over the Global Ocean from three-dimensional, time-varying velocity fields.
#
# **key functions:** 
# - `LatitudeCircles` computes integration paths that follow latitude circles
# - `ThroughFlow` computes transports through these integration paths

# ### Time mean, vertically integrated transports

# +
using MeshArrays
include("demo_trsp_prep.jl")

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

# ### Northward, total transport

# +
UVmean=Dict("U"=>TrspX,"V"=>TrspY,"dimensions"=>["x","y"]);
LC=LatitudeCircles(-89.0:89.0,GridVariables);

T=Array{Float64,1}(undef,length(LC));
for i=1:length(LC)
   T[i]=ThroughFlow(UVmean,LC[i],GridVariables)
end
# -

# ### Plot result

using Plots
lat=-89.0:89.0
plot(lat,T/1e6,xlabel="latitude",ylabel="Sverdrup (10^6 m^3 s^-1)",
    label="ECCOv4r2",title="Northward transport of seawater (Global Ocean)")

# ###  Transport Component Maps
#
# Notice that vector field orientations can differ between the plotted arrays.

include(joinpath(dirname(pathof(MeshArrays)),"Plots.jl"))
heatmap(1e-6*TrspX,clims=(-20.0,20.0))
#heatmap(1e-6*TrspY,clims=(-20.0,20.0))


