using ClimateModels, MITgcmTools, OceanStateEstimation
using Pluto, PlutoUI, PlutoSliderServer, Downloads
import Plots
import CairoMakie

#MC=MITgcm_config(configuration="global_with_exf")
#setup(MC)
# build(MC,"--allow-skip")
# launch(MC)

tmp=ModelConfig(model=ClimateModels.RandomWalker)
setup(tmp)
launch(tmp) 

notebook_url="https://raw.githubusercontent.com/gaelforget/OceanStateEstimation.jl/master/examples/ECCO/ECCO_standard_plots.jl"
path_to_notebook = Downloads.download(notebook_url)
#include(path_to_notebook)

