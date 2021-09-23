using ClimateModels
using MITgcmTools
using Pluto
using PlutoUI
import Plots
import CairoMakie

#MC=MITgcm_config(configuration="global_with_exf")
#setup(MC)
# build(MC,"--allow-skip")
# launch(MC)

tmp=ModelConfig(model=ClimateModels.RandomWalker)
setup(tmp)
launch(tmp)

