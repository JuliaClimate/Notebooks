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
#     display_name: Julia 1.7.0-beta3
#     language: julia
#     name: julia-1.7
# ---

# + [markdown] {"slideshow": {"slide_type": "slide"}}
# # `ClimateTools.jl` and `ClimatePlots.jl`
#
# [ClimateTools.jl](https://juliaclimate.github.io/ClimateTools.jl/dev/) is a collection of commonly-used tools aimed to ease the typical steps in (1) analyzing climate models outputs from netCDF files that follow CF-conventions and (2) creating climate scenarios. [ClimatePlots.jl](https://juliaclimate.github.io/ClimatePlots.jl/dev/) is the associated plotting library.
#
# **Note : This has not been tested since 2020, and may not currently work**

# + {"slideshow": {"slide_type": "subslide"}}
pth_notebooks=joinpath(tempdir(),"tmp_JuliaClimateNotebooks")
!isdir(pth_notebooks) ? mkdir(pth_notebooks) : nothing

if false #set to true if you have not yet installed packages listed below
    using Pkg
    Pkg.add(PackageSpec(name="ClimateTools", rev="master"))
    Pkg.add("PyCall")
    ENV["PYTHON"]=""
    Pkg.build("PyCall")
    Pkg.add(PackageSpec(name="ClimatePlots", rev="master"))

    run(`wget http://esgf-data1.diasjp.net/thredds/fileServer/esg_dataroot/cmip5/output1/MIROC/MIROC5/piControl/day/atmos/day/r1i1p1/v20161012/tas/tas_day_MIROC5_piControl_r1i1p1_20000101-20091231.nc`)
    run(`mv tas_day_MIROC5_piControl_r1i1p1_20000101-20091231.nc $pth_notebooks`)
end

# + [markdown] {"slideshow": {"slide_type": "-"}}
# _Note: `tas_day_MIROC5_piControl_*.nc` was downloaded [here](http://esgf-data1.diasjp.net/thredds/fileServer/esg_dataroot/cmip5/output1/MIROC/MIROC5/piControl/day/atmos/day/r1i1p1/v20161012/tas/tas_day_MIROC5_piControl_r1i1p1_20000101-20091231.nc) by selecting `piControl,day,tas,MIROC5` in [the search engine](https://esgf-node.llnl.gov/search/cmip5/)_
#
# ```
# project=CMIP5, model=MIROC5, Atmosphere and Ocean Research Institute (The University of Tokyo), 
# experiment=pre-industrial control, time_frequency=day, modeling realm=atmos, ensemble=r1i1p1,
# Description: MIROC5 model output prepared for CMIP5 pre-industrial control 
# ```

# + [markdown] {"slideshow": {"slide_type": "slide"}}
# ## Get Meta-Data From File
#
# _Note: uncomment the final line to display the file meta data_

# + {"slideshow": {"slide_type": "-"}}
using ClimateTools, ClimatePlots

p=pth_notebooks
fil="$p/tas_day_MIROC5_piControl_r1i1p1_20000101-20091231.nc"
#fil="$p/clt_day_MIROC5_historical_r4i1p1_19500101-19591231.nc"
d=Dataset(fil);

# + [markdown] {"slideshow": {"slide_type": "slide"}}
# ## Read & Plot A Variable

# + {"slideshow": {"slide_type": "fragment"}}
p1=joinpath(dirname(pathof(ClimateTools)),"../test/data")

#fil1="$p1/orog_fx_GFDL-ESM2G_historicalMisc_r0i0p0.nc"
fil1="$p1/sresa1b_ncar_ccsm3-example.nc"
model1 = load(fil1, "pr", data_units="mm")
contourf(model1, region = "Mollweide");

# + [markdown] {"slideshow": {"slide_type": "slide"}}
# ## Extract Subset And Plot Region
#
# _Note : see `ClimatePlots.jl/src/maps_definition.jl`_

# + {"slideshow": {"slide_type": "fragment"}}
poly_reg = [[NaN -65 -80 -80 -65 -65];[NaN 42 42 52 52 42]]
model2 = load(fil, "tas", poly=poly_reg)
contourf(model2, region = "Quebec");

# + [markdown] {"slideshow": {"slide_type": "slide"}}
# ## Inspect Meta Data

# + {"slideshow": {"slide_type": "fragment"}}
#d
#model1
model2
# -
# ## Read & Plot Another Variable
#
# Here we read data **from a file you would create by running** `DataStructures/03_nctiles.ipynb` after veryfing that the file is indeed found on disk (i.e., it has already been created by a user via `03_nctiles`).

p3=joinpath(pth_notebooks,"/nctiles-newfiles/interp")
tst=sum(occursin.("ETAN.nc",readdir(p3)))>0
if tst
    #access data
    model3 = load("$p3/ETAN.nc", "ETAN")
    #deal with missing values
    m=model3.data
    for i in eachindex(m)
        m[i]>1e10 ? m[i]=NaN : nothing
    end
    model3.data
    #create map    
    contourf(model3, region = "Mollweide")
end



