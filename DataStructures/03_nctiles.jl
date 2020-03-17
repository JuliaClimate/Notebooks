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

# # `NCTiles.jl` Creates Files With Meta Data
#
# [NCTiles.jl](https://gaelforget.github.io/NCTiles.jl/dev/) creates [NetCDF](https://en.wikipedia.org/wiki/NetCDF) files that follow the [CF Metadata Conventions](http://cfconventions.org). It can be used either (1) in stand-alone mode or (2) in combination with [MeshArrays.jl](https://juliaclimate.github.io/MeshArrays.jl/dev/). The examples below include:
#
# 1. Writing mapped model output, on a regular `lat-lon` grid, to a single `NetCDF` file
#   - 2D example
#   - 3D example
# 2. Writing tiled model output, on `C-grid` subdomains, to a collection of `NetCDF` files
#   - 2D surface example
#   - 3D temperature example
#   - 3D staggered vector example

# ### Packages & Helper Functions
#
# _These will be used throughout the notebook_

# +
if false
    using Pkg
    Pkg.add(PackageSpec(name="NCTiles", rev="master"))
    Pkg.add(PackageSpec(name="MITgcmTools", rev="master"))
end

using NCTiles
include("helper_functions.jl");
# -

# ### File Paths & I/O Back-End
#
# _These will be used throughout the notebook_

# +
# File Paths
inputs = "../inputs/nctiles-testcases/"
get_testcases_if_needed(inputs)

outputs = "../outputs/nctiles-newfiles/"
if ~ispath(outputs); mkpath(outputs); end

# I/O Back-End
nc=NCTiles.NCDatasets
# -

# ## Interpolated Data Examples
#
# This example uses 2D and 3D model output that has been interpolated to a rectangular half-degree grid. It reads the data from binary files, adds meta data, and then writes it all to a single `NetCDF` file per model variable.

writedir = joinpath(outputs,"interp") #output files path
if ~ispath(writedir); mkpath(writedir); end

# ### 2D example

# Choose variable to process + specify file set name and precision

nam = "ETAN"
set = "state_2d_set1"
prc = Float32

# Get meta data for the chosen variable. Whithin `field` this defines:
#
# - a `NCvar` struct that sets up the subsequent `write` operation & incl. a `BinData` struct.
# - a `BinData` struct that contains the file names, precision, and array size.

(field,savename,readme)=prep_nctiles_interp(inputs,set,nam,prc);

# Create the NetCDF file and write data to it.

write(field,savename,README=readme);

# ### 3D example

(field,savename,readme)=prep_nctiles_interp(inputs,"WVELMASS","WVELMASS",Float32);
write(field,savename,README=readme);

# ## Tiled Data Examples
#
# This example reads in global variables defined over a collection of subdomain arrays ( _tiles_ ) using `MeshArrays.jl`, and writes them to a collection of `NetCDF` files ( _nctiles_ ) using `NCTiles.jl`.
#
# ### 2D & 3D examples

# +
#output folder name
writedir = joinpath(outputs,"tiled")
~ispath(writedir) ? mkpath(writedir) : nothing

#2D example
(flds,savename,readme)=prep_nctiles_native(inputs,"state_2d_set1","ETAN",Float32)
write(flds,savename,README=readme);

#3D example
(flds,savename,readme)=prep_nctiles_native(inputs,"state_3d_set1","THETA",Float32);
write(flds,savename,README=readme);
# -

# ### 3D vector example
#
# Here we process the three components of a vector field called `UVELMASS`, `VVELMASS` and `WVELMASS`. Note: on a `C-grid` these components are staggered in space.

# +
(flds,savename,readme)=prep_nctiles_native(inputs,"trsp_3d_set1","UVELMASS",Float32);
write(flds,savename,README=readme);

(flds,savename,readme)=prep_nctiles_native(inputs,"trsp_3d_set1","VVELMASS",Float32);
write(flds,savename,README=readme);

(flds,savename,readme)=prep_nctiles_native(inputs,"trsp_3d_set1","WVELMASS",Float32);
write(flds,savename,README=readme);
# -

