using Pkg; 
Pkg.test("ClimateModels")
Pkg.test("IndividualDisplacements")
Pkg.test("MITgcmTools")
Pkg.test("MeshArrays")

using Pluto, PlutoUI, PlutoSliderServer, CairoMakie

using ClimateModels
tmp=ModelConfig(model=ClimateModels.RandomWalker)
setup(tmp)
launch(tmp) 

using Downloads
url="https://raw.githubusercontent.com/JuliaClimate/MeshArrays.jl/master/examples/basics.jl"
include(Downloads.download(url))

