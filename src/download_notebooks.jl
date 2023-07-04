
## Notebooks listed by ClimateModels.notebooks.list()

using ClimateModels
path0="notebooks"
nbs=notebooks.list()
notebooks.download(path0,nbs)

## Notebooks from IndividualDisplacements.jl

using DataFrames
url0="https://raw.githubusercontent.com/JuliaClimate/IndividualDisplacements.jl/master/examples/worldwide/"
nbs2=DataFrame( "folder" => ["IndividualDisplacements.jl","IndividualDisplacements.jl"],
                "file" => ["ECCO_FlowFields.jl","OCCA_FlowFields.jl"],
                "url" => [url0*"ECCO_FlowFields.jl",url0*"OCCA_FlowFields.jl"])
notebooks.download(path0,nbs2)

## Notebooks from JuliaEO23

path_ho="JuliaEO/notebooks/hands_on_sessions/"
path_pl="JuliaEO/notebooks/plenary_sessions/"
path_mv="notebooks/JuliaEO23/"
mkdir(path_mv)

using Git, Pkg

run(`$(git()) clone -b gf05 https://github.com/gaelforget/JuliaEO`)
Pkg.activate(path_ho*"Julia_for_beginners/"); Pkg.update(); Pkg.add("IJulia")
mv(path_ho*"Julia_for_beginners",path_mv*"Julia_for_beginners")
mv(path_pl*"Raster_data_Reading_Manipulating_and_Visualising",path_mv*"Raster_data_demo")
Pkg.activate()
rm("JuliaEO", recursive=true)

run(`$(git()) clone -b gf04 https://github.com/gaelforget/JuliaEO`)
mv(path_ho*"RF_classification_using_marida",path_mv*"Classification_MARIDA")
rm("JuliaEO", recursive=true)

## Notebooks from MarineEcosystemNotebooks

run(`$(git()) clone https://github.com/JuliaOcean/MarineEcosystemNotebooks/`)
mv("MarineEcosystemNotebooks/OceanColor","notebooks/OceanColor")
rm("MarineEcosystemNotebooks", recursive=true)



