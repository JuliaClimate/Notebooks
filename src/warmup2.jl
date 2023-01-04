
using ClimateModels
tmp=ModelConfig(model=ClimateModels.RandomWalker)
setup(tmp)
launch(tmp)

using PlutoSliderServer
fil_in=joinpath("notebooks","ClimateModels.jl","IPCC.jl")
PlutoSliderServer.export_notebook(fil_in)

