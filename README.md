# MeshArrayNotebooks

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/gaelforget/MeshArrayNotebooks/master)

## First notebooks:

This [JuliaCon-2018 presentation](https://youtu.be/RDxAy_zSUvg) introduced the package that later became [MeshArrays.jl](https://github.com/gaelforget/MeshArrays.jl) . It relied on two `Jupyter` notebooks (_provided here_) and predefined grids (_downloaded from `github` by the notebooks if needed_).

- `demo_type.ipynb` illustrates the `gcmfaces` data type, the selection of a `gcmgrid`, and basic file-related (IO) functionalities.
- `demo_exch.ipynb` applies the exchange of data between neighboring arrays in a `gcmfaces` instance, which is another essential feature of `MeshArrays.jl`.

## Added notebooks:

- `demo_smooth.ipynb` uses `MeshArrays.smooth` as done for unit testing the [MeshArrays.jl package](https://github.com/gaelforget/MeshArrays.jl). _This notebook does not require downloading any of the predefined grids._
- `demo_trsp.ipynb` uses `MeshArrays.TransportThrough` and `MeshArrays.LatCircles` to compute transports over the Global Ocean.
- `demo_trsp_prep.jl` (paired to `demo_trsp_prep.ipynb` using [jupytext](https://jupytext.readthedocs.io/en/latest/)) provides `trsp_prep`, `trsp_read`, and `write_bin` for use in `demo_trsp.ipynb`. 

## Activate notebooks:

An interactive version can readily be spun up via the `launch binder` badge.
