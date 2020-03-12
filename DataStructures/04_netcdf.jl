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

# # NCTiles.jl examples

# This notebook demonstrates the use of `NCTiles.jl` in combination with `MeshArrays.jl` (or in standalone mode) to create `NetCDF` files (or read them to memory). Several examples are included:
#
# 1. Write interpolated model output, on a regular `lat-lon` grid, to a single `NetCDF` file
#   - 2D example
#   - 3D example
# 2. Write tiled model output, on a tiled C-grid, to a `NCTiles` collection (multiple `NetCDF` files)
#   - 2D, free surface example
#   - 3D, temperature example
#   - 3D, C-grid vector example

# ### Packages & input files
#
# _These will be used throughout the notebook_

# +
#]add MITgcmTools#gfdev01; add NCTiles; add NCDatasets
# -

using MeshArrays, NCTiles, MITgcmTools

# Helper functions will be used avoid code duplication below:

include("nctiles_helper_functions.jl")
get_testcases_if_needed()

# ### Back-end and file paths
#
# _These will be used throughout the notebook_

# +
# Back-end
nc=NCTiles.NCDatasets

# Paths
datadir = "../inputs/nctiles-testcases/"
availdiagsfile = joinpath(datadir,"available_diagnostics.log")
readmefile = joinpath(datadir,"README")
griddir = joinpath(datadir,"grid_float32/")
nativedir = joinpath(datadir,"diags/")
interpdir = joinpath(datadir,"diags_interp/")

resultsdir = "../outputs/nctiles-newfiles/"
if ~ispath(resultsdir); mkpath(resultsdir); end
# -

# ### Set up dimensions, sizes, and meta data

# +
# Dimensions & sizes
prec = Float32
dep_l=-readbin(joinpath(griddir,"RF.data"),prec,(51,1))[2:end]
dep_c=-readbin(joinpath(griddir,"RC.data"),prec,(50,1))[:]
dep_lvar = NCvar("dep_l","m",size(dep_l),dep_l,Dict(["long_name" => "depth","positive"=>"down","standard_name"=>"depth"]),nc)
dep_cvar = NCvar("dep_c","m",size(dep_c),dep_c,Dict(["long_name" => "depth","positive"=>"down","standard_name"=>"depth"]),nc)
nsteps = length(readdir(interpdir * "ETAN"))
timeinterval = 3
time_steps = timeinterval/2:timeinterval:timeinterval*nsteps
time_units = "days since 1992-01-01 0:0:0"
timevar = NCvar("tim",time_units,Inf,time_steps,Dict(("long_name" => "time","standard_name" => "time")),nc)

# Meta data
README = readlines(readmefile)
# -

# ## Interpolated Data Examples

# This example first interpolates 2D and 3D fields to a rectangular half-degree grid. See below for dimension and size definitions. The interpolated data is then written to a single `NetCDF` file for each variable.

lon_c=-179.75:0.5:179.75; lat_c=-89.75:0.5:89.75;
lon_cvar = NCvar("lon_c","degrees_east",size(lon_c),lon_c,Dict("long_name" => "longitude"),nc)
lat_cvar = NCvar("lat_c","degrees_north",size(lat_c),lat_c,Dict("long_name" => "longitude"),nc)
n1,n2,n3 = (length(lon_c),length(lat_c),length(dep_c))

# ### Interpolate

# This section will take the original model output on the LLC90 grid and interpolate it to a rectangular half-degree grid. This will be done using `loop_task1` from [`CbiomesProcessing.jl`](https://github.com/gaelforget/CbiomesProcessing.jl). The following section is currently run using pre-interpolated data produced with [`gcmfaces`](https://github.com/gaelforget/gcmfaces) in Matlab.

# ### Output path
#
# The following path will be used for this part's output.

writedir = joinpath(resultsdir,"interp")
if ~ispath(writedir); mkpath(writedir); end

# ### 2D example

# Choose variable to process and get the corresponding list of input files

dataset = "state_2d_set1"
fldname = "ETAN"
flddatadir = joinpath(interpdir,fldname)
fnames = joinpath.(Ref(flddatadir),filter(x -> occursin(".data",x), readdir(flddatadir)))

# Get meta data for the chosen variable

diaginfo = readAvailDiagnosticsLog(availdiagsfile,fldname)

# Define:
#
# - a `BinData` struct to contain the file names, precision, and array size.
# - a `NCvar` struct that sets up the subsequent `write` operation (incl. `BinData` struct.

flddata = BinData(fnames,prec,(n1,n2))
dims = [lon_cvar, lat_cvar, timevar]
field = NCvar(fldname,diaginfo["units"],dims,flddata,
    Dict("long_name" => diaginfo["title"]),nc)

# Create the NetCDF file and write data to it.

# +
# Create the NetCDF file and populate with dimension and field info
ds,fldvar,dimlist = createfile(joinpath(writedir,fldname*".nc"),field,README)

# Add field and dimension data
addData(fldvar,field)
addDimData.(Ref(ds),field.dims)

# Close the file
close(ds)
# -

# ### 3D example

# +
# Get the filenames for our first dataset and other information about the field.
dataset = "WVELMASS"
fldname = "WVELMASS"
flddatadir = joinpath(interpdir,fldname)
fnames = flddatadir*'/'.*filter(x -> occursin(".data",x), readdir(flddatadir))
diaginfo = readAvailDiagnosticsLog(availdiagsfile,fldname)

# Define the field for writing using an NCvar struct. BinData contains the filenames
# where the data sits so it's only loaded when needed.
flddata = BinData(fnames,prec,(n1,n2,n3))
dims = [lon_cvar, lat_cvar, dep_lvar, timevar]
field = NCvar(fldname,diaginfo["units"],dims,flddata,Dict("long_name" => diaginfo["title"]),nc)

# Create the NetCDF file and populate with dimension and field info
ds,fldvar,dimlist = createfile(joinpath(writedir,fldname*".nc"),field,README)

# Add field and dimension data
addData(fldvar,field)
addDimData.(Ref(ds),field.dims)

# Close the file
close(ds)
# -

# ## Tiled Data Examples

# This example reads in global variables defined over a collection of subdomain arrays (_tiles_) using `MeshArrays.jl`, and writes them to a collection of `NetCDF` files (_nctiles_) using `NCTiles.jl`

# ### Output path
#
# The following path will be used for this part's output.

writedir = joinpath(resultsdir,"tiled")
~ispath(writedir) ? mkpath(writedir) : nothing

# ### Set up dimensions, sizes, and meta data

# +
# Read grid into MeshArrays
mygrid = GridSpec("LatLonCap",griddir)
mygrid = gcmgrid(griddir,mygrid.class,mygrid.nFaces,
    mygrid.fSize, mygrid.ioSize, Float32, mygrid.read, mygrid.write)
gridvars = addvfgridvars(GridLoad(mygrid))

tilesize = (30,30)
(n1,n2,n3) = (90,1170,50)

# First two dimensions
icvar = NCvar("i_c","1",tilesize[1],1:tilesize[1],Dict("long_name" => "Cartesian coordinate 1"),nc)
jcvar = NCvar("j_c","1",tilesize[2],1:tilesize[2],Dict("long_name" => "Cartesian coordinate 2"),nc)
iwvar = NCvar("i_w","1",tilesize[1],1:tilesize[1],Dict("long_name" => "Cartesian coordinate 1"),nc)
jwvar = NCvar("j_w","1",tilesize[2],1:tilesize[2],Dict("long_name" => "Cartesian coordinate 2"),nc)
isvar = NCvar("i_s","1",tilesize[1],1:tilesize[1],Dict("long_name" => "Cartesian coordinate 1"),nc)
jsvar = NCvar("j_s","1",tilesize[2],1:tilesize[2],Dict("long_name" => "Cartesian coordinate 2"),nc)

# Land masks indicate which points are land, which are ocean
landC = gridvars["hFacC"]
landW = gridvars["hFacW"]
landS = gridvars["hFacS"]
for f in landC.fIndex
    for d in 1:size(landC,2)
        landC[f,d][landC[f,d].==0] .= NaN
        landC[f,d][landC[f,d].>0] .= 1

        landW[f,d][landW[f,d].==0] .= NaN
        landW[f,d][landW[f,d].>0] .= 1

        landS[f,d][landS[f,d].==0] .= NaN
        landS[f,d][landS[f,d].>0] .= 1
    end
end

# Variable indicating the depth/thickness of each cell
thicc = gridvars["DRF"]
thicl = gridvars["DRC"][2:end]

# TileData struct- calculates the locations of each tile in the
# data to retrieve when needed for writing
tilareaC = TileData(gridvars["RAC"],tilesize,mygrid)
tileinfo = tilareaC.tileinfo; numtiles = tilareaC.numtiles
tilareaW = TileData(gridvars["RAW"],tileinfo,tilesize,prec,numtiles)
tilareaS = TileData(gridvars["RAS"],tileinfo,tilesize,prec,numtiles)
tilland3D = TileData(landC,tileinfo,tilesize,prec,numtiles)
tilland2D = TileData(landC[:,1],tileinfo,tilesize,prec,numtiles)
tillandW = TileData(landW,tileinfo,tilesize,prec,numtiles)
tillandS = TileData(landS,tileinfo,tilesize,prec,numtiles)
tillatc = TileData(gridvars["YC"],tileinfo,tilesize,prec,numtiles)
tillonc = TileData(gridvars["XC"],tileinfo,tilesize,prec,numtiles)
tillatw = TileData(gridvars["YW"],tileinfo,tilesize,prec,numtiles)
tillonw = TileData(gridvars["XW"],tileinfo,tilesize,prec,numtiles)
tillats = TileData(gridvars["YS"],tileinfo,tilesize,prec,numtiles)
tillons = TileData(gridvars["XS"],tileinfo,tilesize,prec,numtiles)

# NCvar structs outline fields and their metadata to be written to the file
loncvar = NCvar("lon","degrees_east",[icvar,jcvar],tillonc,Dict("long_name" => "longitude"),nc)
latcvar = NCvar("lat","degrees_north",[icvar,jcvar],tillatc,Dict("long_name" => "latitude"),nc)
lonwvar = NCvar("lon","degrees_east",[iwvar,jwvar],tillonw,Dict("long_name" => "longitude"),nc)
latwvar = NCvar("lat","degrees_north",[iwvar,jwvar],tillatw,Dict("long_name" => "latitude"),nc)
lonsvar = NCvar("lon","degrees_east",[isvar,jsvar],tillons,Dict("long_name" => "longitude"),nc)
latsvar = NCvar("lat","degrees_north",[isvar,jsvar],tillats,Dict("long_name" => "latitude"),nc)
areacvar = NCvar("area","m^2",[icvar,jcvar],tilareaC,Dict(["long_name" => "grid cell area", "standard_name" => "cell_area"]),nc)
areawvar = NCvar("area","m^2",[iwvar,jwvar],tilareaW,Dict(["long_name" => "grid cell area", "standard_name" => "cell_area"]),nc)
areasvar = NCvar("area","m^2",[isvar,jsvar],tilareaS,Dict(["long_name" => "grid cell area", "standard_name" => "cell_area"]),nc)
land3Dvar = NCvar("land","1",[icvar,jcvar,dep_cvar],tilland3D,Dict(["long_name" => "land mask", "standard_name" => "land_binary_mask"]),nc)
land2Dvar = NCvar("land","1",[icvar,jcvar],tilland2D,Dict(["long_name" => "land mask", "standard_name" => "land_binary_mask"]),nc)
landwvar = NCvar("land","1",[iwvar,jwvar,dep_cvar],tillandW,Dict(["long_name" => "land mask", "standard_name" => "land_binary_mask"]),nc)
landsvar = NCvar("land","1",[isvar,jsvar,dep_cvar],tillandS,Dict(["long_name" => "land mask", "standard_name" => "land_binary_mask"]),nc)
thiccvar = NCvar("thic","m",dep_cvar,thicc,Dict("standard_name" => "cell_thickness"),nc)
thiclvar = NCvar("thic","m",dep_lvar,thicl,Dict("standard_name" => "cell_thickness"),nc)
# -

# ### 2D example

# Choose variable to process and get the corresponding list of input files

dataset = "state_2d_set1"
fldname = "ETAN"
fnames = nativedir*'/'.*filter(x -> (occursin(".data",x) && occursin(dataset,x)), readdir(nativedir))
savepath = joinpath(writedir,fldname)
if ~ispath(savepath); mkpath(savepath); end
savenamebase = joinpath.(Ref(savepath),fldname)
diaginfo = readAvailDiagnosticsLog(availdiagsfile,fldname);

# Prepare dictionary of `NCvar` structs and write to `NetCDF` files.

# +
flddata = BinData(fnames,prec,(n1,n2))
tilfld = TileData(flddata,tilesize,mygrid)

dims = [icvar, jcvar, timevar]
coords = join(replace([dim.name for dim in dims],"i_c" => "lon", "j_c" => "lat")," ")
flds = Dict([fldname => NCvar(fldname,diaginfo["units"],dims,tilfld,Dict(["long_name" => diaginfo["title"], "coordinates" => coords]),nc),
            "lon" => loncvar,
            "lat" => latcvar,
            "area" => areacvar,
            "land" => land2Dvar
])

writeNetCDFtiles(flds,savenamebase,README)
# -

# ### 3D example

# +
# Get the filenames for our first dataset and other information about the field.
dataset = "state_3d_set1"
fldname = "THETA"
fnames = nativedir*'/'.*filter(x -> (occursin(".data",x) && occursin(dataset,x)), readdir(nativedir))
savepath = joinpath(writedir,fldname)
if ~ispath(savepath); mkpath(savepath); end
savenamebase = joinpath.(Ref(savepath),fldname)
diaginfo = readAvailDiagnosticsLog(availdiagsfile,fldname)

# Fields to be written to the file are indicated with a dictionary of NCvar structs.
flddata = BinData(fnames,prec,(n1,n2,n3))
dims = [icvar, jcvar, dep_cvar, timevar]
tilfld = TileData(flddata,tilesize,mygrid)
coords = join(replace([dim.name for dim in dims],"i_c" => "lon", "j_c" => "lat")," ")
flds = Dict([fldname => NCvar(fldname,diaginfo["units"],dims,tilfld,Dict(["long_name" => diaginfo["title"], "coordinates" => coords]),nc),
            "lon" => loncvar,
            "lat" => latcvar,
            "area" => areacvar,
            "land" => land3Dvar,
            "thic" => thiccvar
])

# Write to NetCDF files
writeNetCDFtiles(flds,savenamebase,README)
# -

# ### 3D vector example
#
# Here we process the three staggered components of a vector field (`UVELMASS`, `VVELMASS` and `WVELMASS`). On a `C-grid` these components are staggered in space.
#
# First component : `UVELMASS`

# +
# Get the filenames for our first dataset and create BinData struct
dataset = "trsp_3d_set1"
fldname = "UVELMASS"
fnames = nativedir*'/'.*filter(x -> (occursin(".data",x) && occursin(dataset,x)), readdir(nativedir))
savepath = joinpath(writedir,fldname)
if ~ispath(savepath); mkpath(savepath); end
savenamebase = joinpath.(Ref(savepath),fldname)
diaginfo = readAvailDiagnosticsLog(availdiagsfile,fldname)

# Define field- BinData contains the filenames where the data sits so it's only loaded when needed
flddata = BinData(fnames,prec,(n1,n2,n3))
dims = [iwvar, jwvar, dep_cvar, timevar]
tilfld = TileData(flddata,tilesize,mygrid)
coords = join(replace([dim.name for dim in dims],"i_w" => "lon", "j_w" => "lat")," ")
flds = Dict([fldname => NCvar(fldname,diaginfo["units"],dims,tilfld,Dict(["long_name" => diaginfo["title"], "coordinates" => coords]),nc),
            "lon" => lonwvar,
            "lat" => latwvar,
            "area" => areawvar,
            "land" => landwvar,
            "thic" => thiccvar
])

writeNetCDFtiles(flds,savenamebase,README)
# -

# Second component : `VVELMASS`

# +
# Get the filenames for our first dataset and create BinData struct
dataset = "trsp_3d_set1"
fldname = "VVELMASS"
fnames = nativedir*'/'.*filter(x -> (occursin(".data",x) && occursin(dataset,x)), readdir(nativedir))
savepath = joinpath(writedir,fldname)
if ~ispath(savepath); mkpath(savepath); end
savenamebase = joinpath.(Ref(savepath),fldname)
diaginfo = readAvailDiagnosticsLog(availdiagsfile,fldname)

# Define field- BinData contains the filenames where the data sits so it's only loaded when needed
flddata = BinData(fnames,prec,(n1,n2,n3))
dims = [isvar, jsvar, dep_cvar, timevar]
tilfld = TileData(flddata,tilesize,mygrid)
coords = join(replace([dim.name for dim in dims],"i_s" => "lon", "j_s" => "lat")," ")
flds = Dict([fldname => NCvar(fldname,diaginfo["units"],dims,tilfld,Dict(["long_name" => diaginfo["title"], "coordinates" => coords]),nc),
            "lon" => lonsvar,
            "lat" => latsvar,
            "area" => areasvar,
            "land" => landsvar,
            "thic" => thiccvar
])

writeNetCDFtiles(flds,savenamebase,README)
# -

# Third component : `WVELMASS`

# +
# Get the filenames for our first dataset and create BinData struct
dataset = "trsp_3d_set1"
fldname = "WVELMASS"
fnames = nativedir*'/'.*filter(x -> (occursin(".data",x) && occursin(dataset,x)), readdir(nativedir))
savepath = joinpath(writedir,fldname)
if ~ispath(savepath); mkpath(savepath); end
savenamebase = joinpath.(Ref(savepath),fldname)
diaginfo = readAvailDiagnosticsLog(availdiagsfile,fldname)

# Define field- BinData contains the filenames where the data sits so it's only loaded when needed
flddata = BinData(fnames,prec,(n1,n2,n3))
dims = [icvar, jcvar, dep_lvar, timevar]
tilfld = TileData(flddata,tilesize,mygrid)
coords = join(replace([dim.name for dim in dims],"i_c" => "lon", "j_c" => "lat")," ")
flds = Dict([fldname => NCvar(fldname,diaginfo["units"],dims,tilfld,Dict(["long_name" => diaginfo["title"], "coordinates" => coords]),nc),
            "lon" => loncvar,
            "lat" => latcvar,
            "area" => areacvar,
            "land" => land3Dvar,
            "thic" => thiclvar
])

writeNetCDFtiles(flds,savenamebase,README)
