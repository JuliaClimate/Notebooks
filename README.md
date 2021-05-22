# Global Ocean Notebooks

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/JuliaClimate/GlobalOceanNotebooks/master)
[![DOI](https://zenodo.org/badge/147266407.svg)](https://zenodo.org/badge/latestdoi/147266407)

[Jupyter](https://jupyter.org) / [Julia](https://julialang.org) notebooks that illustrate some of the [JuliaClimate](https://github.com/JuliaClimate/GlobalOceanNotebooks) packages working in concert. 

**MeshArrays.jl**, for example, is used to analyze global ocean transports derived accurately from gridded model output. An important requirement in climate science is to derive transports using native model grid output to allow for maximum precision e.g. in closing energy budgets. 

**IndividualDisplacements.jl** extends this approach by providing a [Lagrangian tracking](Lagrangian_and_Eulerian_specification_of_the_flow_field) framework that readily operates on any model `C-grid` supported by **MeshArrays.jl**. In our examples, model output from the [MITgcm](https://mitgcm.readthedocs.io/en/latest/) are loaded into `MeshArray` using functions provided by **MITgcmTools.jl**.

The **Data Structures** section provide examples for reading and writing files (incl. NetCDF and Zarr files), as well as interpolation of variables, and other common tasks in climate and data science.

<details>
  <summary><b>Examples / Ocean Transports </b></summary>

- `04_transports.ipynb` uses `TransportThrough()` and `LatCircles()` to compute seawater transports between latitude bands. It plots interpolated results over the Global Ocean.
- `05_streamfunction.ipynb` uses `ScalarPotential()` and `VectorPotential()` to compute horizontal streamfunction along with the divergent transport component.
- `06_overturning.ipynb` computes meridional overturning streamfunctions (the _MOC_).
- `07_particles.ipynb` computes particle trajectories that follow a gridded flow field.
</details>

<details>
  <summary><b>Examples / Data Structures </b></summary>
  
- `01_MeshArrays.ipynb` illustrates the main data structures defined in [MeshArrays.jl](https://juliaclimate.github.io/MeshArrays.jl/stable/), data communication between neighboring subdomains, and application to transport modeling.
- `03_nctiles.ipynb` converts binary data into meta-data-rich [NetCDF](https://en.wikipedia.org/wiki/NetCDF) files using [NCTiles.jl](https://gaelforget.github.io/NCTiles.jl/dev) for (1) a simple rectangular grid; (2) a tiled domain distributed over multiple files.
- `04_interpolation.ipynb` illustrates how the geo-spatial interpolation method in `MeshArrays.jl` works and can be used to e.g. produce global maps.
- `05_ZarrCloud.ipynb` accesses climate model output hosted in the cloud, from the [CMIP6](https://bit.ly/2WiWmoh) archive, using `AWS.jl` and `Zarr.jl` via [ClimateModels.jl](https://gaelforget.github.io/ClimateModels.jl/dev/).
</details>

<img src="https://github.com/JuliaClimate/GlobalOceanNotebooks/raw/master/OceanTransports/MOC.png" width="40%"> <img src="https://github.com/JuliaClimate/GlobalOceanNotebooks/raw/master/OceanTransports/ScalarPotential.png" width="40%">

<img src="https://user-images.githubusercontent.com/20276764/119210600-0dc9ba00-ba7b-11eb-96c1-e0f5dc75c838.png" width="40%"> <img src="https://github.com/JuliaClimate/GlobalOceanNotebooks/raw/master/OceanTransports/Streamfunction.png" width="40%">


## Notes

- Each `.ipynb` notebook is paired with a `.jl` file via `jupytext`
- An interactive version can readily be started via the `launch binder` badge
- Data downloaded into the `inputs/` folder can safely be removed afterwards
- Efficiency can be improved in various places or simply through parallelization.
- Please use the [repository issue tracker](https://guides.github.com/features/issues/) for queries, bug reports, new contributions, etc.

