using CSV, DataFrames

function get_from_dataverse(nam::String,pth::String)
    tmp = CSV.File("nctiles_climatology.csv") |> DataFrame!
    ii = findall([occursin("$nam", tmp[i,:name]) for i=1:size(tmp,1)])
    !isdir("$pth"*"$nam") ? mkdir("$pth"*"$nam") : nothing
    for i in ii
        ID=tmp[i,:ID]
        nam1=tmp[i,:name]
        nam2=joinpath("$pth"*"$nam/",nam1)
        run(`wget --content-disposition https://dataverse.harvard.edu/api/access/datafile/$ID`);
        run(`mv $nam1 $nam2`);
    end
end

function get_grid_if_needed()
    if !isdir("../inputs/GRID_LLC90")
        run(`git clone https://github.com/gaelforget/GRID_LLC90 ../inputs/GRID_LLC90`)
    end
end

function read_uv_all(pth::String,mygrid::gcmgrid)
    u=Main.read_nctiles("$pth"*"UVELMASS/UVELMASS","UVELMASS",mygrid)
    v=Main.read_nctiles("$pth"*"VVELMASS/VVELMASS","VVELMASS",mygrid)
    return u,v
end
