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
# # Lagrangian particle tracking
#
# Material particles following ocean currents can be analyzed in terms of trajectories. These can simply be computed by integrating velocities through time within a [Lagrangian framework](https://en.wikipedia.org/wiki/Lagrangian_and_Eulerian_specification_of_the_flow_field). In `Julia` this is easily done using the [IndividualDisplacements.jl](https://JuliaClimate.github.io/IndividualDisplacements.jl/dev/) and [OrdinaryDiffEq.jl](https://docs.juliadiffeq.org/latest) packages.

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## Import software, grid, and velocity fields
#
# 1. pre-requisites
# 2. read variables

# + {"slideshow": {"slide_type": "subslide"}}
#]add MITgcmTools#master; add OrdinaryDiffEq; add IndividualDisplacements#master;

# + {"slideshow": {"slide_type": "-"}, "cell_style": "center"}
using IndividualDisplacements, MeshArrays, OrdinaryDiffEq
using Plots, Statistics, MITgcmTools, DataFrames

include("helper_functions.jl")
get_grid_if_needed()
get_velocity_if_needed()

Γ=read_llc90_grid();

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## Set Gridded Variables
#
# 1. Select depth
# 2. time average & normalize to grid units
# 3. apply exchange function to `u,v,lon,lat`
# 4. store everything in `uv_etc` dictionary

# + {"slideshow": {"slide_type": "-"}}
uvetc=read_uvetc(20,Γ,"../inputs/nctiles_climatology/");

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## Initialize Trajectory Computation
#
# 1. set `duComp` to interpolation function
# 2. set `u0` initial location array

# + {"slideshow": {"slide_type": "-"}}
du_dt=IndividualDisplacements.VelComp!
(u0,du)=initialize_locations(uvetc,10);

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## Compute Trajectories
#
# _Note: `ODEProblem` and `solve` settings can still be refined_
# -

tspan = (0.0,uvetc["t1"]-uvetc["t0"])
prob = ODEProblem(du_dt,u0,tspan,uvetc)
sol = solve(prob,Euler(),dt=uvetc["dt"])
size(sol)

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## Post-Process Trajectories
#
# 1. Copy `sol` to a `DataFrame`
# 2. Map position to lon,lat coordinates

# + {"slideshow": {"slide_type": "subslide"}}
df=postprocess_ODESolution(sol,uvetc);

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## Plot Trajectories
#
#
# For example, you can:
#
# - use either `Makie.jl` via `PlotMakie`
# - or use `PyPlot.jl` via `PlotMapProj`
#

# + {"slideshow": {"slide_type": "-"}}
p=dirname(pathof(IndividualDisplacements));

# + {"slideshow": {"slide_type": "slide"}}
#include(joinpath(p,"../examples/plot_pyplot.jl"));
#PyPlot.figure(); PlotMapProj(df,5000)

#include(joinpath(p,"../examples/plot_makie.jl")); 
#AbstractPlotting.inline!(true); #for Juno, set to false
#scene=PlotMakie(df,5000,180.0) 
##Makie.save("LatLonCap300mDepth.png", scene)

include(joinpath(p,"../examples/plot_plots.jl"));
plt=PlotBasic(df,1000,180.0)
# -


