# GlobalOceanNotebooks

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/JuliaClimate/GlobalOceanNotebooks/master)
[![DOI](https://zenodo.org/badge/147266407.svg)](https://zenodo.org/badge/latestdoi/147266407)

[Jupyter](https://jupyter.org) / [Julia](https://julialang.org) notebooks that illustrate some of the [JuliaClimate](https://github.com/JuliaClimate/GlobalOceanNotebooks) packages working in concert. 

For example, **MeshArrays.jl** is used to analyze global ocean transports derived accurately from gridded model output. An important requirement in climate science is to derive transports using native model grid output to allow for maximum precision e.g. in closing energy budgets. 

**IndividualDisplacements.jl** extends this approach by providing a [Lagrangian tracking](Lagrangian_and_Eulerian_specification_of_the_flow_field) framework that readily operates on any model `C-grid` supported by **MeshArrays.jl**. In our examples, model output from the [MITgcm](https://mitgcm.readthedocs.io/en/latest/) are loaded into `MeshArray` using functions provided by **MITgcmTools.jl**.

**Table of content**

- 1. Ocean Transports
- 0. Data Structures

## 1. Ocean Transports

The following notebooks demonstrate various standard computations related to ocean transports.

- `04_transports.ipynb` uses `TransportThrough()` and `LatCircles()` to compute seawater transports between latitude bands. It plots interpolated results over the Global Ocean.
- `05_streamfunction.ipynb` uses `ScalarPotential()` and `VectorPotential()` to compute horizontal streamfunction along with the divergent transport component.
- `06_overturning.ipynb` computes meridional overturning streamfunctions (the _MOC_).
- `07_particles.ipynb` computes particle trajectories that follow a gridded flow field.

![](https://github.com/JuliaClimate/GlobalOceanNotebooks/raw/master/OceanTransports/MOC.png)         |  ![](https://github.com/JuliaClimate/GlobalOceanNotebooks/raw/master/OceanTransports/LatLonCap300mDepth.png)
:------------------------------:|:---------------------------------:
![](https://github.com/JuliaClimate/GlobalOceanNotebooks/raw/master/OceanTransports/ScalarPotential.png)  |  ![](https://github.com/JuliaClimate/GlobalOceanNotebooks/raw/master/OceanTransports/Streamfunction.png)

## 0. Data Structures

[MeshArrays.jl](https://github.com/juliaclimate/MeshArrays.jl) is a Julia package that handles gridded earth variables. It was introduced in this [JuliaCon-2018 presentation](https://youtu.be/RDxAy_zSUvg) which corresponds to `01_MeshArrays` in this folder.

- `01_MeshArrays.ipynb` illustrates the main data structures defined in `MeshArrays.jl` [(documented here)](https://juliaclimate.github.io/MeshArrays.jl/stable/), the exchange of data between neighboring arrays in a `MeshArray`, and demo's these concepts in a simulation of diffusive transport. 
- `04_netcdf.ipynb` converts binary data into meta-data-rich [NetCDF](https://en.wikipedia.org/wiki/NetCDF) files using `NCTiles.jl` for (1) a simple rectangular grid written to single file; (2) a tiled model domain on a less simple grid written to multiple files.

## Notes

- _Each `.ipynb` notebook is paired with a `.jl` file via `jupytext`_
- _An interactive version can readily be spun up via the `launch binder` badge_
- _Rerunning the examples can involve data downloads into the `inputs/` folder that can safely be removed afterwards_
- _For now, this is serial. Efficiency can be improved in various places or simply through parallelization._
- _Please use the [repository issue tracker](https://guides.github.com/features/issues/) for queries, bug reports, new contributions, etc._

