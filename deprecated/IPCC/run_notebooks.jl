
using ClimateModels
import PlutoSliderServer

function fig1to5(x::ModelConfig)
    pth0=pwd()
    pth01=joinpath(pth0,"page","__site")
    pth=joinpath(x.folder,string(x.ID))
    cd(pth)

    for ii in x.inputs[:notebookIDs]
        fil_in="notebook_0$(ii).jl"
        cp(joinpath(pth0,"IPCC",fil_in),fil_in)
        PlutoSliderServer.export_notebook(fil_in)

        fil_out="notebook_0$(ii).html"
        isdir(pth01) ? cp(fil_out,joinpath(pth01,fil_out))  : nothing
    end

    cd(pth0)

    return x
end 

MC=ModelConfig(model="IPCC-AR6-WG1",configuration=fig1to5,inputs=Dict(:notebookIDs => 1:5))

#setup(MC)
mkdir(joinpath(MC.folder,string(MC.ID)))

fig1to5(MC)
