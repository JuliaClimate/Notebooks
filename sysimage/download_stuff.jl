import MeshArrays
MeshArrays.GRID_LLC90_download()

import OceanStateEstimation
OceanStateEstimation.ECCOdiags_download()
OceanStateEstimation.ECCOdiags_add("release4")

#OceanStateEstimation.ECCOdiags_add("interp_coeffs")
OceanStateEstimation.Downloads.download(
  "https://zenodo.org/record/5784905/files/interp_coeffs_halfdeg.jld2",
  joinpath(OceanStateEstimation.ECCOdiags_path,"interp_coeffs_halfdeg.jld2");
  timeout=60000.0)


