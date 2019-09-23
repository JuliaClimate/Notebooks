# MeshArrayNotebooks

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/gaelforget/MeshArrayNotebooks/master)
[![DOI](https://zenodo.org/badge/147266407.svg)](https://zenodo.org/badge/latestdoi/147266407)

[MeshArrays.jl](https://github.com/gaelforget/MeshArrays.jl) is a Julia package that handles gridded earth variables. **This repo** provides a set of Jupyter notebooks that document core features and functions provided by `MeshArrays.jl`

_Note:_ an interactive version can readily be spun up via the `launch binder` badge.

## Types and Exchanges

This [JuliaCon-2018 presentation](https://youtu.be/RDxAy_zSUvg) introduced the package that later became [MeshArrays.jl](https://github.com/gaelforget/MeshArrays.jl) . It relied on two `Jupyter` notebooks (_provided here_) and predefined grids (_downloaded from `github` by the notebooks if needed_).

- `01_types.ipynb` illustrates the `MeshArray` and `gcmgrid` data types.
- `02_exchanges.ipynb` exchanges data between neighboring arrays in a `MeshArray `

## Transport Functions

- `03_smoothing.ipynb` uses `MeshArrays.smooth` as in the [MeshArrays.jl package](https://github.com/gaelforget/MeshArrays.jl) tests
- `04_transports.ipynb` uses `MeshArrays.TransportThrough` and `MeshArrays.LatCircles` to compute seawater transports over the Global Ocean.

 _Notes:_
 - `03_smoothing.ipynb` does not require downloading any of the predefined grids
 - `prepare_transports.jl` (paired to `demo_trsp_prep.ipynb`) provides `trsp_prep`, `trsp_read`, and `write_bin` to `04_transports.ipynb `

