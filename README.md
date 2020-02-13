# GlobalOceanNotebooks

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/JuliaClimate/MeshArrayNotebooks/master)
[![DOI](https://zenodo.org/badge/147266407.svg)](https://zenodo.org/badge/latestdoi/147266407)

[Jupyter](https://jupyter.org) notebooks related to regional-to-global ocean & climate science in [Julia](https://julialang.org). Initial focus has been on the analysis of ocean transports performed on native model grids (as needed to avoid large errors).

**Table of content**

- 1. Ocean Transports
- 0. Data Structures

_Notes:_ 

- _Each `.ipynb` notebook is paired with a `.jl` file via `jupytext`_
- _An interactive version can readily be spun up via the `launch binder` badge_
- _Please use the [repository issue tracker](https://guides.github.com/features/issues/) for queries, bug reports, new contributions, etc._

<img width="500" src="OceanTransports/MOC.png">

## 1. Ocean Transports

The following notebooks demonstrate various standard computations related to ocean transports.

- `04_transports.ipynb` uses `TransportThrough()` and `LatCircles()` to compute seawater transports between latitude bands. It plots interpolated results over the Global Ocean.
- `05_streamfunction.ipynb` uses `ScalarPotential()` and `VectorPotential()` to compute horizontal streamfunction along with the divergent transport component.
- `06_overturning.ipynb` computes meridional overturning streamfunctions (the _MOC_).
- `07_particles.ipynb` computes particle trajectories that follow a gridded flow field.

_Notes_

- _`prepare_transports.jl` provides the `trsp_prep`, `trsp_read`, and `write_bin` functions to `04_transports ` and `05_streamfunction`_
- `06_overturning.ipynb` and `07_particles.ipynb` require downloading additional data (see notebook header)

## 0. Data Structures

[MeshArrays.jl](https://github.com/juliaclimate/MeshArrays.jl) is a Julia package that handles gridded earth variables. It was introduced in this [JuliaCon-2018 presentation](https://youtu.be/RDxAy_zSUvg) which corresponds to `01_types` and `02_exchanges` in this folder.

- `01_types.ipynb` illustrates the main data structures defined in `MeshArrays.jl` -- `MeshArray`, `gcmarray`, and `gcmgrid` that are [documented here](https://juliaclimate.github.io/MeshArrays.jl/stable/).
- `02_exchanges.ipynb` exchanges data between neighboring arrays in a `MeshArray `
- `03_smoothing.ipynb` uses `smooth()` as done in the unit tests of [MeshArrays.jl](https://github.com/juliaclimate/MeshArrays.jl) 
- `04_netcdf.ipynb` converts binary data to `NetCDF` files using `NCTiles.jl` for (1) simple rectangular grid written to single file; (2) tiled model domain written to multiple files.

_Notes_

- _Predefined grids are downloaded by the notebooks except in `03_smoothing`._
- _Helper functions from `nctiles_helper_functions.jl` are used in `04_netcdf.ipynb`._
- _`04_netcdf.ipynb ` requires downloading additional data (see notebook header)._


