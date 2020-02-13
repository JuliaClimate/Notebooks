
using NCDatasets
# this is needed cause writeNetCDFtiles uses `name` etc 

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

"""
    addvfgridvars(gridvars::Dict)

Function to add `XW`, `YW`, `XS`, and `YS` into gridvars. These provide
    the latitude and longitude for `U/V` vector fields.
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
