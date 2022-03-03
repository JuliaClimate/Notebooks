
import PlutoSliderServer

function run_one_notebook(filename::String)
    pth_in=joinpath(pwd(),"tutorials")
    pth_out=joinpath(pwd(),"page","__site")

    cp(joinpath(pth_in,fil_in),joinpath(pth_out,filename))
    PlutoSliderServer.export_notebook(joinpath(pth_out,filename))
end 

run_one_notebook("NetCDF_basics")
run_one_notebook("NetCDF_advanced.jl")
