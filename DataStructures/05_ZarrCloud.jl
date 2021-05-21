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
#     display_name: Julia 1.6.0
#     language: julia
#     name: julia-1.6
# ---

# # Remote Access To Climate Model Output
#
# - Climate model archive ([CMIP6](https://esgf-node.llnl.gov/search/cmip6/)) is accessed using [AWS.jl](https://github.com/JuliaCloud/AWS.jl) and [Zarr.jl](https://github.com/meggart/Zarr.jl) via [ClimateModels.jl](https://github.com/gaelforget/ClimateModels.jl)
# - Choose `institution_id`, `source_id`, `variable_id` (inside `CMIP6.jl`)
# - Compute and plot (1) time mean global map and (2) time evolving global mean (inside `CMIP6.jl`)

using ClimateModels
p=dirname(pathof(ClimateModels))
include(joinpath(p,"../examples/CMIP6.jl"))


