
import PlutoSliderServer

function run_one_notebook(filename::String)
    pth_in=joinpath(pwd(),"tutorials")
    pth_out=joinpath(pwd(),"page","__site")

    cp(joinpath(pth_in,filename),joinpath(pth_out,filename))
    PlutoSliderServer.export_notebook(joinpath(pth_out,filename))
end 

run_one_notebook("NetCDF_basics.jl")
run_one_notebook("NetCDF_advanced.jl")
run_one_notebook("NetCDF_packages.jl")
run_one_notebook("YAXArrays_demo.jl")
#run_one_notebook("xarray_climarray_etc.jl")
run_one_notebook("GeoJSON_demo.jl")
run_one_notebook("GeoTIFF_demo.jl")
run_one_notebook("Shapefile_demo.jl")
