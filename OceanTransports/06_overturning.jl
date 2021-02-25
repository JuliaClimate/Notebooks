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
# # Meridional Overturning Circulation
#
# Global Ocean transport depictions often involve concepts like the [AMOC](https://en.wikipedia.org/wiki/Atlantic_meridional_overturning_circulation), [Thermohaline Circulation](https://en.wikipedia.org/wiki/Thermohaline_circulation), or [conveyor Belt](http://oceanmotion.org/html/background/ocean-conveyor-belt.html). To apply these concepts to gridded ocean and climate models, one can compute an _overturning streamfunction_ as shown below. For more detail, please refer to [Forget et al, 2015](https://doi.org/10.5194/gmd-8-3071-2015) and the other [GlobalOceanNotebooks](https://github.com/JuliaClimate/GlobalOceanNotebooks).

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Read grid & velocities from file
#
# 1. pre-requisites
# 2. read variables
# 3. conversion to transports

# +
using MeshArrays, Plots, Statistics
include("helper_functions.jl")

pth=MeshArrays.GRID_LLC90
γ=GridSpec("LatLonCap",pth)
Γ=GridLoad(γ)
LC=LatitudeCircles(-89.0:89.0,Γ);
# -

using IndividualDisplacements
IndividualDisplacements.get_ecco_velocity_if_needed();
#IndividualDisplacements.get_occa_velocity_if_needed();

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Compute Overturning Streamfunction
#
# 1. integrate along latitude circles
# 2. integrate from the bottom

# + {"slideshow": {"slide_type": "-"}}
nz=size(Γ["hFacC"],2); nt=12; nl=length(LC)
ov=Array{Float64,3}(undef,nl,nz,nt)

#integrate across latitude circles
for t=1:nt
    (U,V)=read_velocities(Γ["XC"].grid,t)
    (U,V)=convert_velocities(U,V,Γ)
    for z=1:nz
        UV=Dict("U"=>U[:,z],"V"=>V[:,z],"dimensions"=>["x","y"])
        [ov[l,z,t]=ThroughFlow(UV,LC[l],Γ) for l=1:nl]
    end
end

#integrate from bottom
ov=reverse(cumsum(reverse(ov,dims=2),dims=2),dims=2);

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Plot Annual Mean And Variability
# -

x=vec(-89.0:89.0); y=reverse(vec(Γ["RF"][1:end-1])); #coordinate variables

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


