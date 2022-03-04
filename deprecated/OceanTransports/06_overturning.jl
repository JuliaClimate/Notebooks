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
# # Meridional Overturning Circulation
#
# Global Ocean transport depictions often involve concepts like the [AMOC](https://en.wikipedia.org/wiki/Atlantic_meridional_overturning_circulation), [Thermohaline Circulation](https://en.wikipedia.org/wiki/Thermohaline_circulation), or [conveyor Belt](http://oceanmotion.org/html/background/ocean-conveyor-belt.html). To apply these concepts to gridded ocean and climate models, one can compute an _overturning streamfunction_ as shown below. For more detail, please refer to [Forget et al, 2015](https://doi.org/10.5194/gmd-8-3071-2015) and the other [GlobalOceanNotebooks](https://github.com/JuliaClimate/GlobalOceanNotebooks).

# + [markdown] {"slideshow": {"slide_type": "slide"}}
# ### Read grid & velocities from file
#
# 1. pre-requisites
# 2. read variables
# 3. conversion to transports

# +
include("helper_functions.jl")

pth=MeshArrays.GRID_LLC90
γ=GridSpec("LatLonCap",pth)
Γ=GridLoad(γ;option="full")
LC=LatitudeCircles(-89.0:89.0,Γ);

# +
using OceanStateEstimation
OceanStateEstimation.get_ecco_velocity_if_needed();
#OceanStateEstimation.get_occa_velocity_if_needed();

"""
    read_velocities(γ::gcmgrid,t::Int,pth::String)

Read velocity components `u,v` from files in `pth`for time `t`
"""
function read_velocities(γ::gcmgrid,t::Int,pth::String)
    u=read_nctiles("$pth"*"UVELMASS/UVELMASS","UVELMASS",γ,I=(:,:,:,t))
    v=read_nctiles("$pth"*"VVELMASS/VVELMASS","VVELMASS",γ,I=(:,:,:,t))
    return u,v
end

# + [markdown] {"slideshow": {"slide_type": "slide"}}
# ### Compute Overturning Streamfunction
#
# 1. integrate along latitude circles
# 2. integrate from the bottom

# + {"slideshow": {"slide_type": "-"}}
nz=size(Γ.hFacC,2); nt=12; nl=length(LC)
ov=Array{Float64,3}(undef,nl,nz,nt)

#integrate across latitude circles
for t=1:nt
    (U,V)=read_velocities(Γ.XC.grid,t,ECCOclim_path)
    (U,V)=convert_velocities(U,V,Γ)
    for z=1:nz
        UV=Dict("U"=>U[:,z],"V"=>V[:,z],"dimensions"=>["x","y"])
        [ov[l,z,t]=ThroughFlow(UV,LC[l],Γ) for l=1:nl]
    end
end

#integrate from bottom
ov=reverse(cumsum(reverse(ov,dims=2),dims=2),dims=2);

# + [markdown] {"slideshow": {"slide_type": "slide"}}
# ### Plot Annual Mean And Variability
# -

x=vec(-89.0:89.0); y=reverse(vec(Γ.RF[1:end-1])); #coordinate variables

# + {"slideshow": {"slide_type": "fragment"}, "cell_style": "split"}
tmp=dropdims(mean(ov,dims=3),dims=3)
z=reverse(tmp,dims=2); z[z.==0.0].=NaN

contourf(x,y,1e-6*transpose(z),clims=(-40,40),
    title="Overturning mean (Eulerian; in Sv)",titlefontsize=10)
#savefig("MOC_mean.png")
# + {"slideshow": {"slide_type": "fragment"}, "cell_style": "split"}
tmp=dropdims(std(ov,dims=3),dims=3)
z=reverse(tmp,dims=2); z[z.==0.0].=NaN

contourf(x,y,1e-6*transpose(z),clims=(-40,40),
    title="Overturning standard deviation (Eulerian; in Sv)",titlefontsize=10)
#savefig("MOC_std.png")
# -


