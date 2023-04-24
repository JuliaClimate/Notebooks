
using ClimateModels
tmp=ModelConfig(model=ClimateModels.RandomWalker)
setup(tmp)
launch(tmp)

path0="/usr/local/etc/gf/notebooks"

if false

using PlutoSliderServer
#fil_in=joinpath(path0,"ClimateModels.jl","IPCC.jl")
#PlutoSliderServer.export_notebook(fil_in)
fil_in=joinpath(path0,"OceanRobots.jl","SatelliteAltimetry.jl")
PlutoSliderServer.export_notebook(fil_in)
fil_in=joinpath(path0,"IndividualDisplacements.jl","global_ocean_circulation.jl")
PlutoSliderServer.export_notebook(fil_in)
fil_in=joinpath(path0,"OceanStateEstimation.jl","ECCO_standard_plots.jl")
PlutoSliderServer.export_notebook(fil_in)

end

