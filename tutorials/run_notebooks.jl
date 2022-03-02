
import PlutoSliderServer

function NetCDF_basics()
    pth_in=joinpath(pwd(),"tutorials")
    pth_out=joinpath(pwd(),"page","__site")

    fil_in="NetCDF_basics.jl"
    cp(joinpath(pth_in,fil_in),joinpath(pth_out,fil_in))
    PlutoSliderServer.export_notebook(joinpath(pth_out,"NetCDF_basics.jl"))

    return true
end 

NetCDF_basics()
