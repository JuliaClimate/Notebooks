
using ClimateModels
path0="notebooks"
nbs=notebooks.list()
notebooks.download(path0,nbs)

using DataFrames
url0="https://raw.githubusercontent.com/JuliaClimate/IndividualDisplacements.jl/master/examples/worldwide/"
nbs2=DataFrame( "folder" => ["IndividualDisplacements.jl","IndividualDisplacements.jl"],
                "file" => ["ECCO_FlowFields.jl","OCCA_FlowFields.jl"],
                "url" => [url0*"ECCO_FlowFields.jl",url0*"OCCA_FlowFields.jl"])
notebooks.download(path0,nbs2)

##

using Pkg
ENV["PYTHON"]=""
Pkg.build("PyCall")

using Dataverse
(DataAccessApi,NativeApi)=pyDataverse.APIs()

filenames=["exportImage_60arc.tiff","sla_podaac.nc",
           "polygons_EEZ.geojson","polygons_MBON_seascapes.geojson"]
pth0=joinpath(tempdir(),"azores_region_data")

DOI="doi:10.7910/DVN/OYBLGK"
df=pyDataverse.dataset_file_list(DOI)
lst=DataverseDownloads.download_urls(df)

for filename in filenames
 file0=joinpath(pth0,filename)
 !ispath(pth0) ? mkdir(pth0) : nothing
 !isfile(file0) ? DataverseDownloads.download_files(lst,filename,pth0) : nothing
end

