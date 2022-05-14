import MeshArrays
MeshArrays.GRID_LLC90_download()

import OceanStateEstimation
OceanStateEstimation.ECCOdiags_download()
#OceanStateEstimation.ECCOdiags_add("release4")
OceanStateEstimation.ECCOdiags_add("interp_coeffs")

include("../tutorials/list_notebooks.jl")
notebooks=list_notebooks()
download_notebooks("jl",notebooks)
#find . -name "*.jl" |grep notebooks


