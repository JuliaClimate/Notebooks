using MeshArrays, MITgcmTools
# this is needed cause writeNetCDFtiles uses `name` etc

function get_testcases_if_needed(pth)
    if !isdir(pth)
        run(`git clone https://github.com/gaelforget/nctiles-testcases $pth`)
        run(`gunzip $pth/diags/state_3d_set1.0000000732.data.gz`)
        run(`gunzip $pth/diags/state_3d_set1.0000001428.data.gz`)
        run(`gunzip $pth/diags/state_3d_set1.0000002172.data.gz`)
        run(`gunzip $pth/diags/trsp_3d_set1.0000000732.data.gz`)
        run(`gunzip $pth/diags/trsp_3d_set1.0000001428.data.gz`)
        run(`gunzip $pth/diags/trsp_3d_set1.0000002172.data.gz`)
    end
end

function input_file_paths(inputs)
    diaglist = joinpath(inputs,"available_diagnostics.log")
    readme = joinpath(inputs,"README")
    grid = joinpath(inputs,"grid_float32/")
    native = joinpath(inputs,"diags/")
    interp = joinpath(inputs,"diags_interp/")
    return Dict("diaglist" => diaglist, "readme" => readme, "grid" => grid,
    "native" => native, "interp" => interp)
end


function grid_etc_interp(pth)
    lon_c=-179.75:0.5:179.75
    lat_c=-89.75:0.5:89.75
    n1,n2 = (length(lon_c),length(lat_c))

    n3=50
    prec = Float32
    dep_l=-readbin(joinpath(pth["grid"],"RF.data"),prec,(n3+1,1))[2:end]
    dep_c=-readbin(joinpath(pth["grid"],"RC.data"),prec,(n3,1))[:]

    timeinterval = 3
    nsteps = length(readdir(pth["interp"] * "ETAN"))
    time_steps = timeinterval/2:timeinterval:timeinterval*nsteps
    time_units = "days since 1992-01-01 0:0:0"

    lon_c = NCvar("lon_c","degrees_east",size(lon_c),lon_c,Dict("long_name" => "longitude"),nc)
    lat_c = NCvar("lat_c","degrees_north",size(lat_c),lat_c,Dict("long_name" => "latitude"),nc)
    dep_l = NCvar("dep_l","m",size(dep_l),dep_l,Dict(["long_name" => "depth","positive"=>"down","standard_name"=>"depth"]),nc)
    dep_c = NCvar("dep_c","m",size(dep_c),dep_c,Dict(["long_name" => "depth","positive"=>"down","standard_name"=>"depth"]),nc)
    tim = NCvar("tim",time_units,Inf,time_steps,Dict(("long_name" => "time","standard_name" => "time")),nc)

    readme = readlines(pth["readme"])

    return Dict("lon_c" => lon_c, "lat_c" => lat_c, "dep_c" => dep_c,
    "dep_l" => dep_l, "tim" => tim, "readme" => readme,
    "n1" => n1, "n2" => n2, "n3" => n3)
end

function grid_etc_native(pth::Dict)
    n3=50
    prec = Float32
    dep_l=-readbin(joinpath(pth["grid"],"RF.data"),prec,(n3+1,1))[2:end]
    dep_c=-readbin(joinpath(pth["grid"],"RC.data"),prec,(n3,1))[:]

    timeinterval = 3
    nsteps = length(filter(x -> (occursin(".data",x) && occursin("state_2d_set1",x)), readdir(pth["native"])))
    time_steps = timeinterval/2:timeinterval:timeinterval*nsteps
    time_units = "days since 1992-01-01 0:0:0"

    dep_l = NCvar("dep_l","m",size(dep_l),dep_l,Dict(["long_name" => "depth","positive"=>"down","standard_name"=>"depth"]),nc)
    dep_c = NCvar("dep_c","m",size(dep_c),dep_c,Dict(["long_name" => "depth","positive"=>"down","standard_name"=>"depth"]),nc)
    tim = NCvar("tim",time_units,Inf,time_steps,Dict(("long_name" => "time","standard_name" => "time")),nc)

    γ = GridSpec("LatLonCap",pth["grid"])
    γ = gcmgrid(pth["grid"],γ.class,γ.nFaces,γ.fSize, γ.ioSize, prec, γ.read, γ.write)
    Γ = GridLoad(γ)
    GridAddWS!(Γ)

    tilesize = (30,30)
    (n1,n2) = (90,1170)

    # First two dimensions
    icvar = NCvar("i_c","1",tilesize[1],1:tilesize[1],Dict("long_name" => "Cartesian coordinate 1"),nc)
    jcvar = NCvar("j_c","1",tilesize[2],1:tilesize[2],Dict("long_name" => "Cartesian coordinate 2"),nc)
    iwvar = NCvar("i_w","1",tilesize[1],1:tilesize[1],Dict("long_name" => "Cartesian coordinate 1"),nc)
    jwvar = NCvar("j_w","1",tilesize[2],1:tilesize[2],Dict("long_name" => "Cartesian coordinate 2"),nc)
    isvar = NCvar("i_s","1",tilesize[1],1:tilesize[1],Dict("long_name" => "Cartesian coordinate 1"),nc)
    jsvar = NCvar("j_s","1",tilesize[2],1:tilesize[2],Dict("long_name" => "Cartesian coordinate 2"),nc)

    # Land masks indicate which points are land, which are ocean
    landC = Γ["hFacC"]
    landW = Γ["hFacW"]
    landS = Γ["hFacS"]
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
    thicc = Γ["DRF"]
    thicl = Γ["DRC"][2:end]

    # TileData struct- calculates the locations of each tile in the
    # data to retrieve when needed for writing
    tilareaC = TileData(Γ["RAC"],tilesize,γ)
    tileinfo = tilareaC.tileinfo; numtiles = tilareaC.numtiles
    tilareaW = TileData(Γ["RAW"],tileinfo,tilesize,prec,numtiles)
    tilareaS = TileData(Γ["RAS"],tileinfo,tilesize,prec,numtiles)
    tilland3D = TileData(landC,tileinfo,tilesize,prec,numtiles)
    tilland2D = TileData(landC[:,1],tileinfo,tilesize,prec,numtiles)
    tillandW = TileData(landW,tileinfo,tilesize,prec,numtiles)
    tillandS = TileData(landS,tileinfo,tilesize,prec,numtiles)
    tillatc = TileData(Γ["YC"],tileinfo,tilesize,prec,numtiles)
    tillonc = TileData(Γ["XC"],tileinfo,tilesize,prec,numtiles)
    tillatw = TileData(Γ["YW"],tileinfo,tilesize,prec,numtiles)
    tillonw = TileData(Γ["XW"],tileinfo,tilesize,prec,numtiles)
    tillats = TileData(Γ["YS"],tileinfo,tilesize,prec,numtiles)
    tillons = TileData(Γ["XS"],tileinfo,tilesize,prec,numtiles)

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
    land3Dvar = NCvar("land","1",[icvar,jcvar,dep_c],tilland3D,Dict(["long_name" => "land mask", "standard_name" => "land_binary_mask"]),nc)
    land2Dvar = NCvar("land","1",[icvar,jcvar],tilland2D,Dict(["long_name" => "land mask", "standard_name" => "land_binary_mask"]),nc)
    landwvar = NCvar("land","1",[iwvar,jwvar,dep_c],tillandW,Dict(["long_name" => "land mask", "standard_name" => "land_binary_mask"]),nc)
    landsvar = NCvar("land","1",[isvar,jsvar,dep_c],tillandS,Dict(["long_name" => "land mask", "standard_name" => "land_binary_mask"]),nc)
    thiccvar = NCvar("thic","m",dep_c,thicc,Dict("standard_name" => "cell_thickness"),nc)
    thiclvar = NCvar("thic","m",dep_l,thicl,Dict("standard_name" => "cell_thickness"),nc)

    readme = readlines(pth["readme"])

    return Dict(
    "icvar" => icvar, "iwvar" => iwvar, "isvar" => isvar,
    "jcvar" => jcvar, "jwvar" => jwvar, "jsvar" => jsvar,
    "loncvar" => loncvar, "lonwvar" => lonwvar, "lonsvar" => lonsvar,
    "latcvar" => latcvar, "latwvar" => latwvar, "latsvar" => latsvar,
    "areacvar" => areacvar, "areawvar" => areawvar, "areasvar" => areasvar,
    "land3Dvar" => land3Dvar, "land2Dvar" => land2Dvar,
    "landwvar" => landwvar, "landsvar" => landsvar,
    "thiccvar" => thiccvar, "thiclvar" => thiclvar,
    "dep_c" => dep_c,"dep_l" => dep_l,"tim" => tim,
    "n1" => n1, "n2" => n2, "n3" => n3, "mygrid" => γ,
    "tilesize" => tilesize, "numtiles" => numtiles, "readme" => readme)
end
