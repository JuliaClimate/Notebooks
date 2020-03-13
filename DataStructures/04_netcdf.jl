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
    Pkg.add(PackageSpec(name="MITgcmTools", rev="master"))
    Pkg.add(PackageSpec(name="NCTiles", rev="master"))
    Pkg.add("NCDatasets")
end

using MeshArrays, NCTiles, MITgcmTools

include("nctiles_helper_functions.jl");
# -

# ### File Paths & I/O Back-End
#
# _These will be used throughout the notebook_

# +
# File Paths
inputs = "../inputs/nctiles-testcases/"
get_testcases_if_needed(inputs)
pth=input_file_paths(inputs)

outputs = "../outputs/nctiles-newfiles/"
if ~ispath(outputs); mkpath(outputs); end

# I/O Back-End
nc=NCTiles.NCDatasets
# -

# ## Interpolated Data Examples
#
#
# This example uses 2D and 3D model output that has been interpolated to a rectangular half-degree grid. It reads the data from binary files, adds meta data, and then writes it all to a single `NetCDF` file per model variable. 
#
# First, we need to define coordinate variables, array sizes, and meta data:

# +
writedir = joinpath(outputs,"interp") #output files path
if ~ispath(writedir); mkpath(writedir); end

Γ = grid_etc_interp(pth) #dimensions, sizes, and meta data
# -

# ### 2D example

# Choose variable to process and get the corresponding list of input files

prec = Float32
dataset = "state_2d_set1"
fldname = "ETAN"
flddatadir = joinpath(pth["interp"],fldname)
fnames = joinpath.(Ref(flddatadir),filter(x -> occursin(".data",x), readdir(flddatadir)))

# Get meta data for the chosen variable

diaginfo = readAvailDiagnosticsLog(pth["diaglist"],fldname)

# Define:
#
# - a `BinData` struct to contain the file names, precision, and array size.
# - a `NCvar` struct that sets up the subsequent `write` operation (incl. `BinData` struct.

flddata = BinData(fnames,prec,(Γ["n1"],Γ["n2"]))
dims = [Γ["lon_c"],Γ["lat_c"],Γ["tim"]]
field = NCvar(fldname,diaginfo["units"],dims,flddata,
    Dict("long_name" => diaginfo["title"]),nc)

# Create the NetCDF file and write data to it.

# +
# Create the NetCDF file and populate with dimension and field info
ds,fldvar,dimlist = createfile(joinpath(writedir,fldname*".nc"),field,Γ["readme"])

# Add field and dimension data
addData(fldvar,field)
addDimData.(Ref(ds),field.dims)

# Close the file
close(ds)
# -

# ### 3D example

Γ["readme"]

# +
# Get the filenames for our first dataset and other information about the field.
dataset = "WVELMASS"
fldname = "WVELMASS"
flddatadir = joinpath(pth["interp"],fldname)
fnames = flddatadir*'/'.*filter(x -> occursin(".data",x), readdir(flddatadir))
diaginfo = readAvailDiagnosticsLog(pth["diaglist"],fldname)

# Define the field for writing using an NCvar struct. BinData contains the filenames
# where the data sits so it's only loaded when needed.
flddata = BinData(fnames,prec,(Γ["n1"],Γ["n2"],Γ["n3"]))
dims = [Γ["lon_c"],Γ["lat_c"],Γ["dep_l"],Γ["tim"]]
field = NCvar(fldname,diaginfo["units"],dims,flddata,Dict("long_name" => diaginfo["title"]),nc)

# Create the NetCDF file and populate with dimension and field info
ds,fldvar,dimlist = createfile(joinpath(writedir,fldname*".nc"),field,Γ["readme"])

# Add field and dimension data
addData(fldvar,field)
addDimData.(Ref(ds),field.dims)

# Close the file
close(ds)
# -

# ## Tiled Data Examples
#
# This example reads in global variables defined over a collection of subdomain arrays (_tiles_) using `MeshArrays.jl`, and writes them to a collection of `NetCDF` files (_nctiles_) using `NCTiles.jl`.
#
# First, we need to define coordinate variables, array sizes, and meta data:

# +
writedir = joinpath(outputs,"tiled")
~ispath(writedir) ? mkpath(writedir) : nothing

include("nctiles_helper_functions.jl")
Γ=grid_etc_native(pth);
# -

# ### 2D example

# Choose variable to process and get the corresponding list of input files

prec = Float32
dataset = "state_2d_set1"
fldname = "ETAN"
fnames = pth["native"]*'/'.*filter(x -> (occursin(".data",x) && occursin(dataset,x)), readdir(pth["native"]))
savepath = joinpath(writedir,fldname)
if ~ispath(savepath); mkpath(savepath); end
savenamebase = joinpath.(Ref(savepath),fldname)
diaginfo = readAvailDiagnosticsLog(pth["diaglist"],fldname);

flddata = BinData(fnames,prec,(Γ["n1"],Γ["n2"]))

# Prepare dictionary of `NCvar` structs and write to `NetCDF` files.

# +
flddata = BinData(fnames,prec,(Γ["n1"],Γ["n2"]))
tilfld = TileData(flddata,Γ["tilesize"],Γ["mygrid"])
numtiles = Γ["numtiles"]

dims = [Γ["icvar"],Γ["jcvar"],Γ["tim"]]
coords = join(replace([dim.name for dim in dims],"i_c" => "lon", "j_c" => "lat")," ")
flds = Dict([fldname => NCvar(fldname,diaginfo["units"],dims,tilfld,Dict(["long_name" => diaginfo["title"], "coordinates" => coords]),nc),
            "lon" => Γ["loncvar"],
            "lat" => Γ["latcvar"],
            "area" => Γ["areacvar"],
            "land" => Γ["land2Dvar"]
])

writeNetCDFtiles(flds,savenamebase,Γ["readme"])
# -

# ### 3D example

# +
# Get the filenames for our first dataset and other information about the field.
prec = Float32
dataset = "state_3d_set1"
fldname = "THETA"
fnames = pth["native"]*'/'.*filter(x -> (occursin(".data",x) && occursin(dataset,x)), readdir(pth["native"]))
savepath = joinpath(writedir,fldname)
if ~ispath(savepath); mkpath(savepath); end
savenamebase = joinpath.(Ref(savepath),fldname)
diaginfo = readAvailDiagnosticsLog(pth["diaglist"],fldname)

# Fields to be written to the file are indicated with a dictionary of NCvar structs.
flddata = BinData(fnames,prec,(Γ["n1"],Γ["n2"],Γ["n3"]))
dims = [Γ["icvar"],Γ["jcvar"],Γ["dep_c"],Γ["tim"]]
tilfld = TileData(flddata,Γ["tilesize"],Γ["mygrid"])
coords = join(replace([dim.name for dim in dims],"i_c" => "lon", "j_c" => "lat")," ")
flds = Dict([fldname => NCvar(fldname,diaginfo["units"],dims,tilfld,Dict(["long_name" => diaginfo["title"], "coordinates" => coords]),nc),
            "lon" => Γ["loncvar"],
            "lat" => Γ["latcvar"],
            "area" => Γ["areacvar"],
            "land" => Γ["land3Dvar"],
            "thic" => Γ["thiccvar"]
])

# Write to NetCDF files
writeNetCDFtiles(flds,savenamebase,Γ["readme"])
# -

# ### 3D vector example
#
# Here we process the three staggered components of a vector field (`UVELMASS`, `VVELMASS` and `WVELMASS`). On a `C-grid` these components are staggered in space.
#
# First component : `UVELMASS`

# +
# Get the filenames for our first dataset and create BinData struct
prec = Float32
dataset = "trsp_3d_set1"
fldname = "UVELMASS"
fnames = pth["native"]*'/'.*filter(x -> (occursin(".data",x) && occursin(dataset,x)), readdir(pth["native"]))
savepath = joinpath(writedir,fldname)
if ~ispath(savepath); mkpath(savepath); end
savenamebase = joinpath.(Ref(savepath),fldname)
diaginfo = readAvailDiagnosticsLog(pth["diaglist"],fldname)

# Define field- BinData contains the filenames where the data sits so it's only loaded when needed
flddata = BinData(fnames,prec,(Γ["n1"],Γ["n2"],Γ["n3"]))
dims = [Γ["iwvar"],Γ["jwvar"],Γ["dep_c"],Γ["tim"]]
tilfld = TileData(flddata,Γ["tilesize"],Γ["mygrid"])
coords = join(replace([dim.name for dim in dims],"i_w" => "lon", "j_w" => "lat")," ")
flds = Dict([fldname => NCvar(fldname,diaginfo["units"],dims,tilfld,Dict(["long_name" => diaginfo["title"], "coordinates" => coords]),nc),
            "lon" => Γ["lonwvar"],
            "lat" => Γ["latwvar"],
            "area" => Γ["areawvar"],
            "land" => Γ["landwvar"],
            "thic" => Γ["thiccvar"]
        ])

writeNetCDFtiles(flds,savenamebase,Γ["readme"])
# -

# Second component : `VVELMASS`

# +
# Get the filenames for our first dataset and create BinData struct
prec = Float32
dataset = "trsp_3d_set1"
fldname = "VVELMASS"
fnames = pth["native"]*'/'.*filter(x -> (occursin(".data",x) && occursin(dataset,x)), readdir(pth["native"]))
savepath = joinpath(writedir,fldname)
if ~ispath(savepath); mkpath(savepath); end
savenamebase = joinpath.(Ref(savepath),fldname)
diaginfo = readAvailDiagnosticsLog(pth["diaglist"],fldname)

# Define field- BinData contains the filenames where the data sits so it's only loaded when needed
flddata = BinData(fnames,prec,(Γ["n1"],Γ["n2"],Γ["n3"]))
dims = [Γ["isvar"],Γ["jsvar"],Γ["dep_c"],Γ["tim"]]
tilfld = TileData(flddata,Γ["tilesize"],Γ["mygrid"])
coords = join(replace([dim.name for dim in dims],"i_s" => "lon", "j_s" => "lat")," ")
flds = Dict([fldname => NCvar(fldname,diaginfo["units"],dims,tilfld,Dict(["long_name" => diaginfo["title"], "coordinates" => coords]),nc),
            "lon" => Γ["lonsvar"],
            "lat" => Γ["latsvar"],
            "area" => Γ["areasvar"],
            "land" => Γ["landsvar"],
            "thic" => Γ["thiccvar"]
])

writeNetCDFtiles(flds,savenamebase,Γ["readme"])
# -

# Third component : `WVELMASS`

# +
# Get the filenames for our first dataset and create BinData struct
prec = Float32
dataset = "trsp_3d_set1"
fldname = "WVELMASS"
fnames = pth["native"]*'/'.*filter(x -> (occursin(".data",x) && occursin(dataset,x)), readdir(pth["native"]))
savepath = joinpath(writedir,fldname)
if ~ispath(savepath); mkpath(savepath); end
savenamebase = joinpath.(Ref(savepath),fldname)
diaginfo = readAvailDiagnosticsLog(pth["diaglist"],fldname)

# Define field- BinData contains the filenames where the data sits so it's only loaded when needed
flddata = BinData(fnames,prec,(Γ["n1"],Γ["n2"],Γ["n3"]))
dims = [Γ["icvar"],Γ["jcvar"],Γ["dep_l"],Γ["tim"]]
tilfld = TileData(flddata,Γ["tilesize"],Γ["mygrid"])
coords = join(replace([dim.name for dim in dims],"i_c" => "lon", "j_c" => "lat")," ")
flds = Dict([fldname => NCvar(fldname,diaginfo["units"],dims,tilfld,Dict(["long_name" => diaginfo["title"], "coordinates" => coords]),nc),
            "lon" => Γ["loncvar"],
            "lat" => Γ["latcvar"],
            "area" => Γ["areacvar"],
            "land" => Γ["land3Dvar"],
            "thic" => Γ["thiclvar"]
])

writeNetCDFtiles(flds,savenamebase,Γ["readme"])
# -


