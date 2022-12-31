
using ClimateModels
tmp=ModelConfig(model=ClimateModels.RandomWalker)
setup(tmp)
launch(tmp)

if true
 using Pluto, PlutoUI, PlutoSliderServer, CairoMakie
 fil_in=joinpath(dirname(pathof(ClimateModels)),"..", "examples","IPCC.jl")
 PlutoSliderServer.export_notebook(fil_in)
end


