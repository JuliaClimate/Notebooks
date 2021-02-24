using MeshArrays, MITgcmTools
# this is needed cause writeNetCDFtiles uses `name` etc

"""
    get_testcases_if_needed(pth)

Download and decompress input files if needed.
"""
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

"""
    input_file_paths(inputs)

Put all folder and file paths in a dictionnary.
"""
function input_file_paths(inputs)
    diaglist = joinpath(inputs,"available_diagnostics.log")
    readme = joinpath(inputs,"README")
    grid = joinpath(inputs,"grid_float32/")
    native = joinpath(inputs,"diags/")
    interp = joinpath(inputs,"diags_interp/")
    return Dict("diaglist" => diaglist, "readme" => readme, "grid" => grid,
    "native" => native, "interp" => interp)
end

"""
    dimensions_etc_interp(pth::Dict)

Format grid variables as NCvar instances.
"""
function dimensions_etc_interp(pth::Dict)
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

"""
    dimensions_etc_native(pth::Dict)

Format grid variables as NCvar instances via MeshArrays.
"""
function dimensions_etc_native(pth::Dict)
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

    tilesize = (90,90)
    (n1,n2) = (90,1170)

    # First two dimensions
    i_c = NCvar("i_c","1",tilesize[1],1:tilesize[1],Dict("long_name" => "Cartesian coordinate 1"),nc)
    j_c = NCvar("j_c","1",tilesize[2],1:tilesize[2],Dict("long_name" => "Cartesian coordinate 2"),nc)
    i_w = NCvar("i_w","1",tilesize[1],1:tilesize[1],Dict("long_name" => "Cartesian coordinate 1"),nc)
    j_w = NCvar("j_w","1",tilesize[2],1:tilesize[2],Dict("long_name" => "Cartesian coordinate 2"),nc)
    i_s = NCvar("i_s","1",tilesize[1],1:tilesize[1],Dict("long_name" => "Cartesian coordinate 1"),nc)
    j_s = NCvar("j_s","1",tilesize[2],1:tilesize[2],Dict("long_name" => "Cartesian coordinate 2"),nc)

    # Land masks indicate which points are land, which are ocean
    land_c = Γ["hFacC"]
    land_w = Γ["hFacW"]
    land_s = Γ["hFacS"]
    for f in land_c.fIndex
        for d in 1:size(land_c,2)
            land_c[f,d][land_c[f,d].==0] .= NaN
            land_c[f,d][land_c[f,d].>0] .= 1

            land_w[f,d][land_w[f,d].==0] .= NaN
            land_w[f,d][land_w[f,d].>0] .= 1

            land_s[f,d][land_s[f,d].==0] .= NaN
            land_s[f,d][land_s[f,d].>0] .= 1
        end
    end
    land2d_c=land_c[:,1]

    # Variable indicating the depth/thickness of each cell
    thic_c = Γ["DRF"]
    thic_l = Γ["DRC"][2:end]

    # TileData struct- calculates the locations of each tile in the
    # data to retrieve when needed for writing
    area_c = TileData(Γ["RAC"],tilesize,γ)
    tileinfo = area_c.tileinfo; numtiles = area_c.numtiles
    area_w = TileData(Γ["RAW"],tileinfo,tilesize,prec,numtiles)
    area_s = TileData(Γ["RAS"],tileinfo,tilesize,prec,numtiles)
    land_c = TileData(land_c,tileinfo,tilesize,prec,numtiles)
    land2d_c = TileData(land2d_c,tileinfo,tilesize,prec,numtiles)
    land_w = TileData(land_w,tileinfo,tilesize,prec,numtiles)
    land_s = TileData(land_s,tileinfo,tilesize,prec,numtiles)
    lat_c = TileData(Γ["YC"],tileinfo,tilesize,prec,numtiles)
    lon_c = TileData(Γ["XC"],tileinfo,tilesize,prec,numtiles)
    lat_w = TileData(Γ["YW"],tileinfo,tilesize,prec,numtiles)
    lon_w = TileData(Γ["XW"],tileinfo,tilesize,prec,numtiles)
    lat_s = TileData(Γ["YS"],tileinfo,tilesize,prec,numtiles)
    lon_s = TileData(Γ["XS"],tileinfo,tilesize,prec,numtiles)

    # NCvar structs outline fields and their metadata to be written to the file
    lon_c = NCvar("lon","degrees_east",[i_c,j_c],lon_c,Dict("long_name" => "longitude"),nc)
    lat_c = NCvar("lat","degrees_north",[i_c,j_c],lat_c,Dict("long_name" => "latitude"),nc)
    lon_w = NCvar("lon","degrees_east",[i_w,j_w],lon_w,Dict("long_name" => "longitude"),nc)
    lat_w = NCvar("lat","degrees_north",[i_w,j_w],lat_w,Dict("long_name" => "latitude"),nc)
    lon_s = NCvar("lon","degrees_east",[i_s,j_s],lon_s,Dict("long_name" => "longitude"),nc)
    lat_s = NCvar("lat","degrees_north",[i_s,j_s],lat_s,Dict("long_name" => "latitude"),nc)
    area_c = NCvar("area","m^2",[i_c,j_c],area_c,Dict(["long_name" => "grid cell area", "standard_name" => "cell_area"]),nc)
    area_w = NCvar("area","m^2",[i_w,j_w],area_w,Dict(["long_name" => "grid cell area", "standard_name" => "cell_area"]),nc)
    area_s = NCvar("area","m^2",[i_s,j_s],area_s,Dict(["long_name" => "grid cell area", "standard_name" => "cell_area"]),nc)
    land_c = NCvar("land","1",[i_c,j_c,dep_c],land_c,Dict(["long_name" => "land mask", "standard_name" => "land_binary_mask"]),nc)
    land2d_c = NCvar("land","1",[i_c,j_c],land2d_c,Dict(["long_name" => "land mask", "standard_name" => "land_binary_mask"]),nc)
    land_w = NCvar("land","1",[i_w,j_w,dep_c],land_w,Dict(["long_name" => "land mask", "standard_name" => "land_binary_mask"]),nc)
    land_s = NCvar("land","1",[i_s,j_s,dep_c],land_s,Dict(["long_name" => "land mask", "standard_name" => "land_binary_mask"]),nc)
    thic_c = NCvar("thic","m",dep_c,thic_c,Dict("standard_name" => "cell_thickness"),nc)
    thic_l = NCvar("thic","m",dep_l,thic_l,Dict("standard_name" => "cell_thickness"),nc)

    readme = readlines(pth["readme"])

    return Dict(
    "i_c" => i_c, "i_w" => i_w, "i_s" => i_s,
    "j_c" => j_c, "j_w" => j_w, "j_s" => j_s,
    "lon_c" => lon_c, "lon_w" => lon_w, "lon_s" => lon_s,
    "lat_c" => lat_c, "lat_w" => lat_w, "lat_s" => lat_s,
    "area_c" => area_c, "area_w" => area_w, "area_s" => area_s,
    "land_c" => land_c, "land2d_c" => land2d_c,
    "land_w" => land_w, "land_s" => land_s,
    "thic_c" => thic_c, "thic_l" => thic_l,
    "dep_c" => dep_c,"dep_l" => dep_l,"tim" => tim,
    "n1" => n1, "n2" => n2, "n3" => n3, "γ" => γ,
    "tilesize" => tilesize, "numtiles" => numtiles, "readme" => readme)
end

"""
    prep_nctiles_interp(inputs,set,nam,prc)

Setup NCvar instance for chosen variable that can then be written to file.
"""
function prep_nctiles_interp(inputs,set,nam,prc)
    pth=input_file_paths(inputs)
    Λ = dimensions_etc_interp(pth) #dimensions, sizes, and meta data

    flddatadir = joinpath(pth["interp"],nam)
    fnames = joinpath.(Ref(flddatadir),filter(x -> occursin(".data",x), readdir(flddatadir)))
    diaginfo = read_available_diagnostics(nam, filename=pth["diaglist"])
    if diaginfo["levs"]==1 && diaginfo["code"][2]=='M'
        flddata = BinData(fnames,prc,(Λ["n1"],Λ["n2"]))
        dims = [Λ["lon_c"],Λ["lat_c"],Λ["tim"]]
    elseif diaginfo["levs"]>1 && diaginfo["code"][2]=='M' && diaginfo["code"][9]=='L'
        flddata = BinData(fnames,prc,(Λ["n1"],Λ["n2"],Λ["n3"]))
        dims = [Λ["lon_c"],Λ["lat_c"],Λ["dep_l"],Λ["tim"]]
    else
        error("other cases remain to be implemented...")
    end
    field = NCvar(nam,diaginfo["units"],dims,flddata,
    Dict("long_name" => diaginfo["title"]),nc)
    savename=joinpath(writedir,nam*".nc")
    readme=Λ["readme"]

    #nct=...
    return field,savename,readme
end

"""
    prep_nctiles_native(inputs,set,nam,prc)

Setup NCvar array for chosen variable that can then be written to file. The
    NCvar array includes ancillary variables like lon and lat.
"""
function prep_nctiles_native(inputs,set,nam,prc)
    pth=input_file_paths(inputs)
    Λ = dimensions_etc_native(pth) #dimensions, sizes, and meta data

    fnames = pth["native"]*'/'.*filter(x -> (occursin(".data",x) && occursin(set,x)), readdir(pth["native"]))
    savepath = joinpath(writedir,nam)
    if ~ispath(savepath); mkpath(savepath); end
    savename = joinpath.(Ref(savepath),nam)
    diaginfo = read_available_diagnostics(nam, filename=pth["diaglist"])
    if diaginfo["levs"]==1 && diaginfo["code"][2]=='M'
        flddata = BinData(fnames,prc,(Λ["n1"],Λ["n2"]))
        dims = [Λ["i_c"],Λ["j_c"],Λ["tim"]]
        coords = join(replace([dim.name for dim in dims],"i_c" => "lon", "j_c" => "lat")," ")
        tmp=Dict("lon" => Λ["lon_c"],"lat" => Λ["lat_c"],
        "area" => Λ["area_c"],"land" => Λ["land2d_c"])
    elseif diaginfo["levs"]>1 && diaginfo["code"][2]=='M' && diaginfo["code"][9]=='M'
        flddata = BinData(fnames,prc,(Λ["n1"],Λ["n2"],Λ["n3"]))
        dims = [Λ["i_c"],Λ["j_c"],Λ["dep_c"],Λ["tim"]]
        coords = join(replace([dim.name for dim in dims],"i_c" => "lon", "j_c" => "lat")," ")
        tmp=Dict(    "lon" => Λ["lon_c"],"lat" => Λ["lat_c"],
        "area" => Λ["area_c"],"land" => Λ["land_c"],"thic" => Λ["thic_c"])
    elseif diaginfo["levs"]>1 && diaginfo["code"][2]=='U' && diaginfo["code"][9]=='M'
        flddata = BinData(fnames,prc,(Λ["n1"],Λ["n2"],Λ["n3"]))
        dims = [Λ["i_w"],Λ["j_w"],Λ["dep_c"],Λ["tim"]]
        coords = join(replace([dim.name for dim in dims],"i_w" => "lon", "j_w" => "lat")," ")
        tmp=Dict(    "lon" => Λ["lon_w"],"lat" => Λ["lat_w"],
        "area" => Λ["area_w"],"land" => Λ["land_w"],"thic" => Λ["thic_c"])
    elseif diaginfo["levs"]>1 && diaginfo["code"][2]=='V' && diaginfo["code"][9]=='M'
        flddata = BinData(fnames,prc,(Λ["n1"],Λ["n2"],Λ["n3"]))
        dims = [Λ["i_s"],Λ["j_s"],Λ["dep_c"],Λ["tim"]]
        coords = join(replace([dim.name for dim in dims],"i_s" => "lon", "j_s" => "lat")," ")
        tmp=Dict(    "lon" => Λ["lon_s"],"lat" => Λ["lat_s"],
        "area" => Λ["area_s"],"land" => Λ["land_s"],"thic" => Λ["thic_c"])
    elseif diaginfo["levs"]>1 && diaginfo["code"][2]=='M' && diaginfo["code"][9]=='L'
        flddata = BinData(fnames,prc,(Λ["n1"],Λ["n2"],Λ["n3"]))
        dims = [Λ["i_c"],Λ["j_c"],Λ["dep_l"],Λ["tim"]]
        coords = join(replace([dim.name for dim in dims],"i_c" => "lon", "j_c" => "lat")," ")
        tmp=Dict(    "lon" => Λ["lon_c"],"lat" => Λ["lat_c"],
        "area" => Λ["area_c"],"land" => Λ["land_c"],"thic" => Λ["thic_l"])
    else
        error("other cases remain to be implemented...")
    end

    tilfld = TileData(flddata,Λ["tilesize"],Λ["γ"])
    flds = Dict([nam => NCvar(nam,diaginfo["units"],dims,tilfld,Dict(["long_name" => diaginfo["title"], "coordinates" => coords]),nc)])
    merge!(flds,tmp)

    #nct=...
    return flds,savename,readme
end
