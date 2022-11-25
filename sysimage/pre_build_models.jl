
## pyDataverse

using PyCall, Conda, Pkg

ENV["PYTHON"]=""
Pkg.build("PyCall")

Conda.pip_interop(true)
Conda.pip("install", "pyDataverse")
Conda.pip("install", "fair")

##

using ClimateModels
pth=dirname(pathof(ClimateModels))

## Hector

Pkg.add("IniFile")
Pkg.add("Suppressor")
fil=joinpath(pth,"..","examples","Hector_module.jl")
include(fil)
H=demo.Hector_config()
run(H)

f1=joinpath(pathof(H),"hector","src","hector")
f2=joinpath(homedir(),"hector")
mv(f1,f2)

## Speedy

fil=joinpath(pth,"..","examples","Speedy_module.jl")
include(fil)
H=demo.SPEEDY_config()
run(H)

f1=joinpath(pathof(H),"bin","speedy")
f2=joinpath(homedir(),"speedy")
mv(f1,f2)

## MITgcm

using MITgcmTools
MITgcm_download()
MC=MITgcm_config(configuration="tutorial_global_oce_biogeo")
run(MC)

