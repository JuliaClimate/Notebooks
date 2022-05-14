import MeshArrays
MeshArrays.GRID_LLC90_download()

import OceanStateEstimation
OceanStateEstimation.ECCOdiags_download()
OceanStateEstimation.ECCOdiags_add("release4")

#OceanStateEstimation.ECCOdiags_add("interp_coeffs")
import Downloads
Downloads.download(
  "https://zenodo.org/record/5784905/files/interp_coeffs_halfdeg.jld2",
  joinpath(OceanStateEstimation.ECCOdiags_path,"interp_coeffs_halfdeg.jld2");
  timeout=60000.0)

include("../tutorials/list_notebooks.jl")
notebooks=list_notebooks()
download_notebooks("jl",notebooks)
#find . -name "*.jl" |grep notebooks


