# MeshArrayNotebooks

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/gaelforget/MeshArrayNotebooks/master)
[![DOI](https://zenodo.org/badge/147266407.svg)](https://zenodo.org/badge/latestdoi/147266407)

[MeshArrays.jl](https://github.com/gaelforget/MeshArrays.jl) is a Julia package that handles gridded earth variables. **This repository** provides Jupyter notebooks (+ `.jl` files) that document functionalities supported by `MeshArrays.jl`. 

_Notes:_ 

- each `.ipynb` notebook is paired with a `.jl` file via `jupytext`
- an interactive version can readily be spun up via the `launch binder` badge
- `03_smoothing.ipynb` does not require downloading a grid; other notebooks do.
- `prepare_transports.jl` provides `trsp_prep`, `trsp_read`, and `write_bin` to `04_transports.ipynb ` and `05_streamfunction.ipynb`

## Ocean Transports

The following notebooks demonstrate various standard computations related to ocean transports.

- `03_smoothing.ipynb` uses `smooth()` as done in the unit tests of [MeshArrays.jl](https://github.com/gaelforget/MeshArrays.jl) 
- `04_transports.ipynb` uses `TransportThrough()` and `LatCircles()` to compute seawater transports between latitude bands. It plots interpolated results over the Global Ocean.
- `05_streamfunction.ipynb` uses `ScalarPotential()` and `VectorPotential()` to compute a streamfunction along with the divergent transport component.

## Data Structures

This [JuliaCon-2018 presentation](https://youtu.be/RDxAy_zSUvg) about the precursor of [MeshArrays.jl](https://github.com/gaelforget/MeshArrays.jl) corresponds to two `Jupyter` notebooks provided here. _Note: predefined grids are downloaded by the notebooks if needed._

- `01_types.ipynb` illustrates the `MeshArray` and `gcmgrid` data types.
- `02_exchanges.ipynb` exchanges data between neighboring arrays in a `MeshArray `

## IO
- `06_nctiles.ipynb` uses the `NCTiles.jl` package to write data to `NetCDF` files. Examples include interpolated data on a rectangular grid read from binary files and written to single `NetCDF` files, and larger data on the `LLC90` grid read in using `MeshArrays` and written to multiple tiled `NetCDF` files.
