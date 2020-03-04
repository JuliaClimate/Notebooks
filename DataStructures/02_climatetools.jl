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
# # `ClimateTools.jl` and `ClimatePlots.jl`
#
# [ClimateTools.jl](https://juliaclimate.github.io/ClimateTools.jl/dev/) is a collection of commonly-used tools aimed to ease the typical steps in (1) analyzing climate models outputs from netCDF files that follow CF-conventions and (2) creating climate scenarios. [ClimatePlots.jl](https://juliaclimate.github.io/ClimatePlots.jl/dev/) is the associated plotting library.

# + {"slideshow": {"slide_type": "subslide"}, "cell_type": "markdown"}
# _Note: `tas_day_MIROC5_piControl_*.nc` was downloaded [here](http://esgf-data1.diasjp.net/thredds/fileServer/esg_dataroot/cmip5/output1/MIROC/MIROC5/piControl/day/atmos/day/r1i1p1/v20161012/tas/tas_day_MIROC5_piControl_r1i1p1_20000101-20091231.nc) by selecting `piControl,day,tas,MIROC5` in [the search engine](https://esgf-node.llnl.gov/search/cmip5/)_
#
# ```
# project=CMIP5, model=MIROC5, Atmosphere and Ocean Research Institute (The University of Tokyo), 
# experiment=pre-industrial control, time_frequency=day, modeling realm=atmos, ensemble=r1i1p1,
# Description: MIROC5 model output prepared for CMIP5 pre-industrial control 
# ```

# +
#]add ClimateTools#master; add ClimatePlots#master

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## Inspect A Data Set File Via NCDataSets
#
# Uncomment the final line to display the file meta data.

# + {"slideshow": {"slide_type": "-"}}
using ClimateTools, ClimatePlots
p=joinpath(dirname(pathof(ClimateTools)),"../test/data")

fil="$p/tas_day_MIROC5_piControl_r1i1p1_20000101-20091231.nc"
#fil="$p/clt_day_MIROC5_historical_r4i1p1_19500101-19591231.nc"
d=Dataset(fil);

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## Extract Subset And Plot Region
#
# See : `ClimatePlots.jl/src/maps_definition.jl`
#
# Note : not `mapclimgrid(C1, region = "Quebec")` as in docs

# + {"slideshow": {"slide_type": "fragment"}}
poly_reg = [[NaN -65 -80 -80 -65 -65];[NaN 42 42 52 52 42]]
C1 = load(fil, "tas", poly=poly_reg)
contourf(C1, region = "Quebec");

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## Read & Plot Another Variable

# + {"slideshow": {"slide_type": "fragment"}}
#fil="$p/orog_fx_GFDL-ESM2G_historicalMisc_r0i0p0.nc"
fil="$p/sresa1b_ncar_ccsm3-example.nc"
C2 = load(fil, "pr", data_units="mm")
contourf(C2, region = "Mollweide");

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## Inspect Meta Data In Each Variable

# + {"slideshow": {"slide_type": "fragment"}}
#C1
C2
# -


