
import PlutoSliderServer

function VizNc()
    pth_in=joinpath(pwd(),"DataStructures")
    pth_out=joinpath(pwd(),"page","__site")

    fil_in="VizNc.jl"
    cp(joinpath(pth_in,fil_in),joinpath(pth_out,fil_in))
    PlutoSliderServer.export_notebook(joinpath(pth_out,"VizNc.jl"))

    return true
end 

VizNc()
