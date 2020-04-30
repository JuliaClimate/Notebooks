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

# # Access Climate Model Output Using `Zarr.jl`
#
# - Access climate model archive ([CMIP6](https://esgf-node.llnl.gov/search/cmip6/)) via `AWSCore.jl` and `Zarr.jl` 
# - Choose `institution_id`, `source_id`, `variable_id`
# - Compute and plot (1) time mean global map and (2) time evolving global mean
#
# _This notebook was partly inspired by [this earlier example](https://github.com/pangeo-data/pangeo-julia-examples) from @rabernat_

# + {"slideshow": {"slide_type": "subslide"}}
#initialize julia packages and connection to cloud storage

using Zarr, AWSCore, DataFrames, CSV, CFTime, Dates, Statistics, Plots

⅁ = AWSCore.aws_config(creds=nothing, region="", 
    service_host="googleapis.com", service_name="storage")
#println(typeof(⅁))
#println(supertype(typeof(⅁)))

# + {"slideshow": {"slide_type": "subslide"}}
#get list of contents for cloud storage unit

β = S3Store("cmip6","", aws=⅁, listversion=1)
#println(typeof(β))

ξ = CSV.read(IOBuffer(β["cmip6-zarr-consolidated-stores.csv"]))
unique(ξ[!,:activity_id])
#unique(ξ[!,:institution_id])

# + {"slideshow": {"slide_type": "subslide"}}
#choose model and variable

S=["IPSL","IPSL-CM6A-LR","tas"] #institution_id, source_id, variable_id

# get model grid cell areas

ii=findall( (ξ[!,:source_id].==S[2]).&(ξ[!,:variable_id].=="areacella") )
μ=ξ[ii,:]
i1=findfirst("cmip6",μ.zstore[end])[end]+2
P = μ.zstore[end][i1:end]

ζ = zopen(S3Store("cmip6", P, aws=⅁, listversion=1))
Å = ζ["areacella"][:, :];

#heatmap(ζ["lon"], ζ["lat"], transpose(Å))

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## Plot One Model Solution
#
# Here we first select one ensemble member for the chosen model. We then compute and plot a (1) time mean global map and (2) time evolving global mean

# + {"slideshow": {"slide_type": "subslide"}}
# get model solution ensemble list

i=findall( (ξ[!,:activity_id].=="CMIP").&(ξ[!,:table_id].=="Amon").&
            (ξ[!,:variable_id].==S[3]).&(ξ[!,:experiment_id].=="historical").&
            (ξ[!,:institution_id].==S[1]) )
μ=ξ[i,:]
unique(μ[!,:institution_id])

# + {"slideshow": {"slide_type": "subslide"}}
# access one model ensemble member

i1=findfirst("cmip6",μ.zstore[end])[end]+2
P = μ.zstore[end][i1:end]
ζ = zopen(S3Store("cmip6", P, aws=⅁, listversion=1))
size(ζ[S[3]])

# + {"slideshow": {"slide_type": "subslide"}}
# time mean global map

m = convert(Array{Union{Missing, Float32},3},ζ[S[3]][:,:,:])
m = dropdims(mean(m,dims=3),dims=3)

heatmap(ζ["lon"], ζ["lat"], transpose(m),title="time mean")

# + {"slideshow": {"slide_type": "subslide"}}
# time evolving global mean

t = ζ["time"]
t = timedecode(t[:], t.attrs["units"], t.attrs["calendar"])

y = ζ[S[3]]
ylab=y.attrs["long_name"]*" in "*y.attrs["units"]

y=y[:,:,:]
y=[sum(y[:, :, i].*Å) for i in 1:length(t)]./sum(Å)

plot(t, y,xlabel="time",ylabel=ylab,label=S[1],title="global mean")
# -

