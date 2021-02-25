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
# # Lagrangian particle tracking
#
# Materials and particles that tend to follow ocean currents can be analyzed in terms of trajectories. These are simply computed by integrating velocities over time within a [Lagrangian framework](https://en.wikipedia.org/wiki/Lagrangian_and_Eulerian_specification_of_the_flow_field). 
#
# In `Julia` this is easily done e.g. using the [IndividualDisplacements.jl](https://JuliaClimate.github.io/IndividualDisplacements.jl/dev/) package.

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## 1. Software, Grid, And Background Map

# + {"slideshow": {"slide_type": "-"}, "cell_style": "center"}
using IndividualDisplacements, DataFrames, Statistics, CSV, Plots
pth=dirname(pathof(IndividualDisplacements))
include(joinpath(pth,"../examples/helper_functions.jl"));

# +
IndividualDisplacements.get_ecco_velocity_if_needed() #download data if needed

𝑃,𝐷=global_ocean_circulation(k=20,ny=2); #grid etc

# +
lon=[i for i=-179.:2.0:179., j=-89.:2.0:89.]
lat=[j for i=-179.:2.0:179., j=-89.:2.0:89.]

df=DataFrame(CSV.File("interp_coeffs.csv"))
λ=(f=reshape(df.f,length(lon[:]),4), i=reshape(df.i,length(lon[:]),4),
    j=reshape(df.j,length(lon[:]),4), w=reshape(df.w,length(lon[:]),4))
OceanDepth=Interpolate(𝐷.Γ["Depth"],λ.f,λ.i,λ.j,λ.w)
OceanDepth=reshape(OceanDepth,size(lon));

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## 2. Initialize Individuals

# + {"slideshow": {"slide_type": "-"}}
𝐷.🔄(𝑃,𝐷,0.0) #update velocity fields (here, to Dec and Jan bracketing t=0.0)

np=100
xy = init_global_randn(np,𝐷)
df=DataFrame(x=xy[1,:],y=xy[2,:],f=xy[3,:]) #initial positions

𝐼=Individuals(𝑃,df.x[1:np],df.y[1:np],df.f[1:np]) #Individuals data structure

fieldnames(typeof(𝐼))

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## 3. Compute Trajectories

# +
𝑇=(0.0,𝐼.𝑃.𝑇[2]) #first half of January
∫!(𝐼,𝑇) #mid-Dec to mid-Jan

for m=1:12
    𝐷.🔄(𝑃,𝐷,0.0) #update velocity fields
    ∫!(𝐼) #integrate forward by one more month
end

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## 4. Post-Processing

# + {"slideshow": {"slide_type": "subslide"}}
add_lonlat!(𝐼.🔴,𝐷.XC,𝐷.YC)
𝐼.🔴[end-3:end,:]

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## 5. Plot Trajectories
#
# In this example we simply map out individual positions (red to blue) over a map of ocean depth (log10).

# +
plt=contourf(vec(lon[:,1]),vec(lat[1,:]),permutedims(OceanDepth),clims=(-2500.,5000.),c = :grays, colorbar=false)
xli=extrema(lon)

🔴_by_t = groupby(𝐼.🔴, :t)
lo=deepcopy(🔴_by_t[1].lon); lo[findall(lo.<xli[1])]=lo[findall(lo.<xli[1])].+360
scatter!(lo,🔴_by_t[1].lat,markersize=1.5,c=:red,leg=:none,marker = (:circle, stroke(0)))
lo=deepcopy(🔴_by_t[end].lon); lo[findall(lo.<xli[1])]=lo[findall(lo.<xli[1])].+360
scatter!(lo,🔴_by_t[end].lat,markersize=1.5,c=:blue,leg=:none,marker = (:dot, stroke(0)))
# -


