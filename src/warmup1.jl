
if false

using Pkg
ENV["PYTHON"]=""
Pkg.build("PyCall")

using Dataverse
(DataAccessApi,NativeApi)=pyDataverse.APIs()

end

##

using IJulia

##

if false

filenames=["exportImage_60arc.tiff"]
#filenames=[filenames...,"sla_podaac.nc","polygons_EEZ.geojson","polygons_MBON_seascapes.geojson"]
pth0=joinpath(tempdir(),"azores_region_data")

DOI="doi:10.7910/DVN/OYBLGK"
df=pyDataverse.dataset_file_list(DOI)
lst=DataverseDownloads.download_urls(df)

for filename in filenames
 file0=joinpath(pth0,filename)
 !ispath(pth0) ? mkdir(pth0) : nothing
 !isfile(file0) ? DataverseDownloads.download_files(lst,filename,pth0) : nothing
end

end

