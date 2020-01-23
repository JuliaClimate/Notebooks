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
#     display_name: Julia 1.1.0
#     language: julia
#     name: julia-1.1
# ---

# # NCTiles.jl examples

# This notebook demonstrates the use of `NCTiles.jl` in combination with `MeshArrays.jl` or in standalone mode. Several test cases are included:
#
# 1. Write regular array data to single NetCDF file
#   - 2D example
#   - 3D example
# 2. Write tiled data to multiple NetCDF files ("nctiles")
#   - 2D example
#   - 3D, temperature example
#   - 3D, C-grid vector example
#   
# To run these test cases, please first download and decompress files as follows.
#
# ```
# git clone https://github.com/gaelforget/nctiles-testcases
# gunzip nctiles-testcases/diags/*.gz
# ```

if !isdir("../inputs/nctiles-testcases")
    run(`git clone https://github.com/gaelforget/nctiles-testcases ../inputs/nctiles-testcases`)
end
#run(`gunzip nctiles-testcases/diags/trsp_3d_set1.0000000732.data.gz`)

# # Setup

# Setting the paths and dimensions that will be used throughout this notebook.

# +
using Pkg; Pkg.add(["NCTiles","NCDatasets","NetCDF"])
using NCTiles,NCDatasets,NetCDF,MeshArrays

# Set Paths
datadir = "../inputs/nctiles-testcases/"
availdiagsfile = joinpath(datadir,"available_diagnostics.log")
readmefile = joinpath(datadir,"README")
griddir = joinpath(datadir,"grid_float32/")
nativedir = joinpath(datadir,"diags/")
interpdir = joinpath(datadir,"diags_interp/")

resultsdir = "../outputs/nctiles-newfiles/"
if ~ispath(resultsdir); mkpath(resultsdir); end

# Dimensions
prec = Float32
dep_l=-readbin(joinpath(griddir,"RF.data"),prec,(51,1))[2:end]
dep_c=-readbin(joinpath(griddir,"RC.data"),prec,(50,1))[:]
dep_lvar = NCvar("dep_l","m",size(dep_l),dep_l,Dict(["long_name" => "depth","positive"=>"down","standard_name"=>"depth"]),NCDatasets)
dep_cvar = NCvar("dep_c","m",size(dep_c),dep_c,Dict(["long_name" => "depth","positive"=>"down","standard_name"=>"depth"]),NCDatasets)
nsteps = 240
timeinterval = 3
time_steps = timeinterval/2:timeinterval:timeinterval*nsteps
time_units = "days since 1992-01-01 0:0:0"
timevar = NCvar("tim",time_units,Inf,time_steps,Dict(("long_name" => "time","standard_name" => "time")),NCDatasets)

README = readlines(readmefile)
# -

# # Interpolated Data Test Case

# This example first interpolates 2D and 3D data to a rectangular half-degree grid. This interpolated data is then written to a single NetCDF file per field.

# Setup paths and dimensions used for interpolated data.

# Interpolated dimensions
lon_c=-179.75:0.5:179.75; lat_c=-89.75:0.5:89.75;
lon_cvar = NCvar("lon_c","degrees_east",size(lon_c),lon_c,Dict("long_name" => "longitude"),NCDatasets)
lat_cvar = NCvar("lat_c","degrees_north",size(lat_c),lat_c,Dict("long_name" => "longitude"),NCDatasets)
n1,n2,n3 = (length(lon_c),length(lat_c),length(dep_c))

# ## Interpolate

# This section will take the original model output on the LLC90 grid and interpolate it to a rectangular half-degree grid. This will be done using `loop_task1` from [`CbiomesProcessing.jl`](https://github.com/gaelforget/CbiomesProcessing.jl). The following section is currently run using pre-interpolated data produced with [`gcmfaces`](https://github.com/gaelforget/gcmfaces) in Matlab.

# ## Write interpolated data to NetCDF Files

writedir = joinpath(resultsdir,"interp")
if ~ispath(writedir); mkpath(writedir); end

# ### 2D Field ETAN

# Get the filenames for our first dataset and other information about the field.

dataset = "state_2d_set1"
fldname = "ETAN"
flddatadir = joinpath(interpdir,fldname)
fnames = joinpath.(Ref(flddatadir),filter(x -> occursin(".data",x), readdir(flddatadir)))
diaginfo = readAvailDiagnosticsLog(availdiagsfile,fldname)

# Define the field for writing using an NCvar struct. BinData contains the filenames where the data sits so it's only loaded when needed.

flddata = BinData(fnames,prec,(n1,n2))
dims = [lon_cvar, lat_cvar, timevar]
field = NCvar(fldname,diaginfo["units"],dims,flddata,Dict("long_name" => diaginfo["title"]),NCDatasets)

# Create the NetCDF file and write the data to the file.

# +
# Create the NetCDF file and populate with dimension and field info
ds,fldvar,dimlist = createfile(joinpath(writedir,fldname*".nc"),field,README)

# Add field and dimension data
addData(fldvar,field)
addDimData.(Ref(ds),field.dims)

# Close the file
close(ds)
# -

# ### 3D Vertical Vector Field WVELMASS

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
field = NCvar(fldname,diaginfo["units"],dims,flddata,Dict("long_name" => diaginfo["title"]),NCDatasets)

# Create the NetCDF file and populate with dimension and field info
ds,fldvar,dimlist = createfile(joinpath(writedir,fldname*".nc"),field,README)

# Add field and dimension data
addData(fldvar,field)
addDimData.(Ref(ds),field.dims)

# Close the file
close(ds)
# -

# # Tiled Test Case

# This example breaks up the data into tiles and writes those tiles to separate NetCDF files. This is done using the `MeshArrays` Julia package for reading in the data and breaking it up into tiles, and `NCTiles.jl` for writing the tiles.

# ## Helper Functions

# Function for writing out tiled data.

# +
"""
    writeNetCDFtiles(flds::Dict,savenamebase::String,README::Array)

Function to write out tiled NetCDF files. Flds should be a Dict of NCVars, 
    savenamebase should be the prefix of the filenames to which the tile 
    number and file exension is added, including full path to the save 
    location, and README should be an Array of strings containing the
    description to write into the files.
"""
function writeNetCDFtiles(flds::Dict,savenamebase::String,README::Array)
    
    savenames = savenamebase*".".*lpad.(string.(1:numtiles),4,"0").*".nc"
    
    datasets = [createfile(savenames[tidx],flds,README, itile = tidx, ntile = length(savenames)) for tidx in 1:length(savenames)]

    ds = [x[1] for x in datasets]
    fldvars = [x[2] for x in datasets]

    for k in keys(flds)
        if isa(flds[k].values,TileData)
            addData(fldvars,flds[k])
        else
            tmpfldvars = [fv[findfirst(isequal(k),name.(fv))] for fv in fldvars]
            addData.(tmpfldvars,Ref(flds[k]))
        end
    end

    for dim in dims
        addDimData.(ds,Ref(dim))
    end

    close.(ds);
    
    return nothing
    
end
# -

# Function for getting the latitude/longitude values for the vector field data (`XW`, `YW` and `XS`,`YS`).

"""
    addvfgridvars(gridvars::Dict)

Function to add XW, YW, XS, and YS to gridvars. These provide 
    the latitude and longitude for vector fields.
"""
function addvfgridvars(gridvars::Dict)
    
    tmpXC=exchange(gridvars["XC"]); tmpYC=exchange(gridvars["YC"])

    gridvars["XW"]=NaN .* gridvars["XC"]; gridvars["YW"]=NaN .* gridvars["YC"];
    gridvars["XS"]=NaN .* gridvars["XC"]; gridvars["YS"]=NaN .* gridvars["YC"];

    for ff=1:mygrid.nFaces
        tmp1=tmpXC[ff][1:end-2,2:end-1]
        tmp2=tmpXC[ff][2:end-1,2:end-1]
        tmp2[tmp2.-tmp1.>180]=tmp2[tmp2.-tmp1.>180].-360;
        tmp2[tmp1.-tmp2.>180]=tmp2[tmp1.-tmp2.>180].+360;
        gridvars["XW"][ff]=(tmp1.+tmp2)./2;

       #
        tmp1=tmpXC[ff][2:end-1,1:end-2]
        tmp2=tmpXC[ff][2:end-1,2:end-1]
        tmp2[tmp2.-tmp1.>180]=tmp2[tmp2.-tmp1.>180].-360;
        tmp2[tmp1.-tmp2.>180]=tmp2[tmp1.-tmp2.>180].+360;
        gridvars["XS"][ff]=(tmp1.+tmp2)./2;

       #
        tmp1=tmpYC[ff][1:end-2,2:end-1]
        tmp2=tmpYC[ff][2:end-1,2:end-1]
        gridvars["YW"][ff]=(tmp1.+tmp2)./2;

       #
        tmp1=tmpYC[ff][2:end-1,1:end-2]
        tmp2=tmpYC[ff][2:end-1,2:end-1]
        gridvars["YS"][ff]=(tmp1.+tmp2)./2;
    end;

    Xmax=180; Xmin=-180;

    gridvars["XS"][findall(gridvars["XS"].<Xmin)]=gridvars["XS"][findall(gridvars["XS"].<Xmin)].+360;
    gridvars["XS"][findall(gridvars["XS"].>Xmax)]=gridvars["XS"][findall(gridvars["XS"].>Xmax)].-360;
    gridvars["XW"][findall(gridvars["XW"].<Xmin)]=gridvars["XW"][findall(gridvars["XW"].<Xmin)].+360;
    gridvars["XW"][findall(gridvars["XW"].>Xmax)]=gridvars["XW"][findall(gridvars["XW"].>Xmax)].-360;
    return gridvars
end

# ## Setup

# Setup paths and dimensions used for interpolated data.

# +
writedir = joinpath(resultsdir,"tiled")
if ~ispath(writedir); mkpath(writedir); end

mygrid = GridSpec("LLC90",joinpath(datadir,"grid_float32/"))
mygrid = gcmgrid(joinpath(datadir,"grid_float32/"),mygrid.class,mygrid.nFaces,
    mygrid.fSize, mygrid.ioSize, Float32, mygrid.read, mygrid.write)
tilesize = (30,30)
(n1,n2,n3) = (90,1170,50)

# First two dimensions
icvar = NCvar("i_c","1",tilesize[1],1:tilesize[1],Dict("long_name" => "Cartesian coordinate 1"),NCDatasets)
jcvar = NCvar("j_c","1",tilesize[2],1:tilesize[2],Dict("long_name" => "Cartesian coordinate 2"),NCDatasets)
iwvar = NCvar("i_w","1",tilesize[1],1:tilesize[1],Dict("long_name" => "Cartesian coordinate 1"),NCDatasets)
jwvar = NCvar("j_w","1",tilesize[2],1:tilesize[2],Dict("long_name" => "Cartesian coordinate 2"),NCDatasets)
isvar = NCvar("i_s","1",tilesize[1],1:tilesize[1],Dict("long_name" => "Cartesian coordinate 1"),NCDatasets)
jsvar = NCvar("j_s","1",tilesize[2],1:tilesize[2],Dict("long_name" => "Cartesian coordinate 2"),NCDatasets)

gridvars = addvfgridvars(GridLoad(mygrid))

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
loncvar = NCvar("lon","degrees_east",[icvar,jcvar],tillonc,Dict("long_name" => "longitude"),NCDatasets)
latcvar = NCvar("lat","degrees_north",[icvar,jcvar],tillatc,Dict("long_name" => "latitude"),NCDatasets)
lonwvar = NCvar("lon","degrees_east",[iwvar,jwvar],tillonw,Dict("long_name" => "longitude"),NCDatasets)
latwvar = NCvar("lat","degrees_north",[iwvar,jwvar],tillatw,Dict("long_name" => "latitude"),NCDatasets)
lonsvar = NCvar("lon","degrees_east",[isvar,jsvar],tillons,Dict("long_name" => "longitude"),NCDatasets)
latsvar = NCvar("lat","degrees_north",[isvar,jsvar],tillats,Dict("long_name" => "latitude"),NCDatasets)
areacvar = NCvar("area","m^2",[icvar,jcvar],tilareaC,Dict(["long_name" => "grid cell area", "standard_name" => "cell_area"]),NCDatasets)
areawvar = NCvar("area","m^2",[iwvar,jwvar],tilareaW,Dict(["long_name" => "grid cell area", "standard_name" => "cell_area"]),NCDatasets)
areasvar = NCvar("area","m^2",[isvar,jsvar],tilareaS,Dict(["long_name" => "grid cell area", "standard_name" => "cell_area"]),NCDatasets)
land3Dvar = NCvar("land","1",[icvar,jcvar,dep_cvar],tilland3D,Dict(["long_name" => "land mask", "standard_name" => "land_binary_mask"]),NCDatasets)
land2Dvar = NCvar("land","1",[icvar,jcvar],tilland2D,Dict(["long_name" => "land mask", "standard_name" => "land_binary_mask"]),NCDatasets)
landwvar = NCvar("land","1",[iwvar,jwvar,dep_cvar],tillandW,Dict(["long_name" => "land mask", "standard_name" => "land_binary_mask"]),NCDatasets)
landsvar = NCvar("land","1",[isvar,jsvar,dep_cvar],tillandS,Dict(["long_name" => "land mask", "standard_name" => "land_binary_mask"]),NCDatasets)
thiccvar = NCvar("thic","m",dep_cvar,thicc,Dict("standard_name" => "cell_thickness"),NCDatasets)
thiclvar = NCvar("thic","m",dep_lvar,thicl,Dict("standard_name" => "cell_thickness"),NCDatasets)
# -

# ## 2D Field ETAN

# Get the filenames for our first dataset and other information about the field.

dataset = "state_2d_set1"
fldname = "ETAN"
fnames = nativedir*'/'.*filter(x -> (occursin(".data",x) && occursin(dataset,x)), readdir(nativedir))
savepath = joinpath(writedir,fldname)
if ~ispath(savepath); mkpath(savepath); end
savenamebase = joinpath.(Ref(savepath),fldname)
diaginfo = readAvailDiagnosticsLog(availdiagsfile,fldname)

# Fields to be written to the file are indicated with a dictionary of NCvar structs. Then write to NetCDF files.

# +
flddata = BinData(fnames,prec,(n1,n2))
dims = [icvar, jcvar, timevar]
tilfld = TileData(flddata,tilesize,mygrid)
coords = join(replace([dim.name for dim in dims],"i_c" => "lon", "j_c" => "lat")," ")
flds = Dict([fldname => NCvar(fldname,diaginfo["units"],dims,tilfld,Dict(["long_name" => diaginfo["title"], "coordinates" => coords]),NCDatasets),
            "lon" => loncvar,
            "lat" => latcvar,
            "area" => areacvar,
            "land" => land2Dvar
]) 

writeNetCDFtiles(flds,savenamebase,README)
# -

# ## 3D Field Theta

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
flds = Dict([fldname => NCvar(fldname,diaginfo["units"],dims,tilfld,Dict(["long_name" => diaginfo["title"], "coordinates" => coords]),NCDatasets),
            "lon" => loncvar,
            "lat" => latcvar,
            "area" => areacvar,
            "land" => land3Dvar,
            "thic" => thiccvar
])

# Write to NetCDF files
writeNetCDFtiles(flds,savenamebase,README)
# -

# ## Vector Field UVELMASS

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
flds = Dict([fldname => NCvar(fldname,diaginfo["units"],dims,tilfld,Dict(["long_name" => diaginfo["title"], "coordinates" => coords]),NCDatasets),
            "lon" => lonwvar, 
            "lat" => latwvar,
            "area" => areawvar,
            "land" => landwvar,
            "thic" => thiccvar
])

writeNetCDFtiles(flds,savenamebase,README)
# -

# ## Vector Field VVELMASS

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
flds = Dict([fldname => NCvar(fldname,diaginfo["units"],dims,tilfld,Dict(["long_name" => diaginfo["title"], "coordinates" => coords]),NCDatasets),
            "lon" => lonsvar,
            "lat" => latsvar,
            "area" => areasvar,
            "land" => landsvar,
            "thic" => thiccvar
])

writeNetCDFtiles(flds,savenamebase,README)
# -

# ## Vector Field WVELMASS

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
flds = Dict([fldname => NCvar(fldname,diaginfo["units"],dims,tilfld,Dict(["long_name" => diaginfo["title"], "coordinates" => coords]),NCDatasets),
            "lon" => loncvar,
            "lat" => latcvar,
            "area" => areacvar,
            "land" => land3Dvar,
            "thic" => thiclvar
])

writeNetCDFtiles(flds,savenamebase,README)
# -


