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
# Material particles that tend to follow ocean currents can be analyzed in terms of trajectories. These can simply be computed by integrating velocities through time within a [Lagrangian framework](https://en.wikipedia.org/wiki/Lagrangian_and_Eulerian_specification_of_the_flow_field). 
#
# In `Julia` this is easily done using the [IndividualDisplacements.jl](https://JuliaClimate.github.io/IndividualDisplacements.jl/dev/) package.

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## 1. Software, Grid, And Velocities

# + {"slideshow": {"slide_type": "-"}, "cell_style": "center"}
using IndividualDisplacements, DataFrames, Statistics
pth=dirname(pathof(IndividualDisplacements))
include(joinpath(pth,"../examples/helper_functions.jl")) 
include(joinpath(pth,"../examples/recipes_plots.jl"))

# +
IndividualDisplacements.get_ecco_velocity_if_needed() #download data if needed

𝑃,𝐷=global_ocean_circulation(k=20,ny=2) #grid etc
ODL=OceanDepthLog(𝐷.Γ) #used for plotting later

fieldnames(typeof(𝑃)) #FlowFields data structure

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
# In this example we simply map out individual positions (red to yellow) over a map of ocean depth (log10).

# + {"slideshow": {"slide_type": "-"}}
map(𝐼,ODL)
