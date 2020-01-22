# GlobalRegionalOceanography.ipynb

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/gaelforget/MeshArrayNotebooks/master)
[![DOI](https://zenodo.org/badge/147266407.svg)](https://zenodo.org/badge/latestdoi/147266407)

Notebooks related to global to regional ocean research, education, and outreach. 


_Notes:_ 

- each `.ipynb` notebook is paired with a `.jl` file via `jupytext`
- an interactive version can readily be spun up via the `launch binder` badge
- please use the [repository issue tracker](https://guides.github.com/features/issues/) for queries, bug reports, new contributions, etc.

## Ocean Transports

The following notebooks demonstrate various standard computations related to ocean transports.

- `04_transports.ipynb` uses `TransportThrough()` and `LatCircles()` to compute seawater transports between latitude bands. It plots interpolated results over the Global Ocean.
- `05_streamfunction.ipynb` uses `ScalarPotential()` and `VectorPotential()` to compute a streamfunction along with the divergent transport component.

_Notes_

- `prepare_transports.jl` provides the `trsp_prep`, `trsp_read`, and `write_bin` functions to `04_transports ` and `05_streamfunction`

## Data Structures

[MeshArrays.jl](https://github.com/juliaclimate/MeshArrays.jl) is a Julia package that handles gridded earth variables. It was introduced in this [JuliaCon-2018 presentation](https://youtu.be/RDxAy_zSUvg) which corresponds to `01_types` and `02_exchanges` in this folder.

- `01_types.ipynb` illustrates the main data structures defined in `MeshArrays.jl` -- `MeshArray`, `gcmarray`, and `gcmgrid` that are [documented here](https://juliaclimate.github.io/MeshArrays.jl/stable/).
- `02_exchanges.ipynb` exchanges data between neighboring arrays in a `MeshArray `
- `03_smoothing.ipynb` uses `smooth()` as done in the unit tests of [MeshArrays.jl](https://github.com/juliaclimate/MeshArrays.jl) 
- `06_nctiles.ipynb` converts binary data to `NetCDF` files using `NCTiles.jl` for (1) simple rectangular grid written to single file; (2) tiled model domain written to multiple files.

_Notes_

- _Predefined grids are downloaded by the notebooks except in `03_smoothing`._

