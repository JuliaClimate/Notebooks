using Pkg; Pkg.add("PlutoSliderServer")

using PlutoSliderServer, ClimateModels
pth=dirname(pathof(ClimateModels))
fil=joinpath(pth,"..","examples","Hector.jl")
PlutoSliderServer.export_notebook(fil)

tmp1=readdir(tempdir())
tst1=[isfile(joinpath(tempdir(),i,"hector","src","hector")) for i in tmp1]
tst2=[!islink(joinpath(tempdir(),i,"hector","src","hector")) for i in tmp1]
ii=findall(tst1.*tst2)[1]
symlink(joinpath(tempdir(),tmp1[ii],"hector","src","hector"),"hector")


