
\begin{section}{title="Overview",name="Overview"}

[Julia](https://julialang.org) notebooks (using [Jupyter](https://jupyter.org) or [Pluto](https://plutojl.org)) that illustrate some of the [JuliaClimate](https://github.com/JuliaClimate/) packages working in concert and within the broader ecosystem. 

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/JuliaClimate/GlobalOceanNotebooks/master)
[![DOI](https://zenodo.org/badge/147266407.svg)](https://zenodo.org/badge/latestdoi/147266407)

The **ClimateModels.jl** package provides an interface to models often used in climate science. Included notebooks can be used to run these models (e.g. in the mybinder cloud) and generate new output. 

A second series of notebooks rather replays model data provided by the **2021 IPCC report** (from the _Intergovernmental Panel on Climate Change_). For additional information about the plots, please refer to the report.

An important requirement in climate science is to derive transports using native model grid output to allow for maximum precision e.g. in closing energy budgets. This is one of the applications of **MeshArrays.jl** -- the computation and analysis of global ocean transports derived accurately from gridded model output. 

**IndividualDisplacements.jl** extends this approach by providing a [particle tracking](https://en.wikipedia.org/wiki/Lagrangian_and_Eulerian_specification_of_the_flow_field) framework that readily operates on climate model `C-grids` (see **MeshArrays.jl**). In the examples, model output from the [MITgcm](https://mitgcm.readthedocs.io/en/latest/) are loaded using functions provided by **MITgcmTools.jl**.

The **Data Structures** section provide examples for reading and writing files (incl. NetCDF and Zarr files), as well as interpolation of variables, and other common tasks in climate and data science.

\end{section}

\begin{section}{title="Sample Plots",name="Plots"}

\begin{center}

\figure{path="https://github.com/JuliaClimate/GlobalOceanNotebooks/raw/master/OceanTransports/MOC.png", width="250", style="border-radius:5px;", caption="Meridional Overturning Streamfunction"} \figure{path="https://user-images.githubusercontent.com/20276764/119210600-0dc9ba00-ba7b-11eb-96c1-e0f5dc75c838.png", width="250", style="border-radius:5px;", caption="Particle Tracking"} 

\figure{path="https://user-images.githubusercontent.com/20276764/135203125-e663713e-48c9-42e0-bbd7-bd4ba222b70a.png", width="250", style="border-radius:5px;", caption="IPCC report fig 1b"} \figure{path="https://user-images.githubusercontent.com/20276764/135203143-ae838319-1a63-4ffe-8f08-1055174b79aa.png", width="250", style="border-radius:5px;", caption="IPCC report fig 2"}

\figure{path="https://user-images.githubusercontent.com/20276764/135203198-a5e2dc49-baee-4d13-a113-5433c074bbff.png", width="250", style="border-radius:5px;", caption="IPCC report fig 3"} \figure{path="https://user-images.githubusercontent.com/20276764/135203214-ce6caece-13d1-49f3-9a70-7fa63d810e9c.png", width="250", style="border-radius:5px;", caption="IPCC report fig 5"}

\figure{path="https://github.com/JuliaClimate/GlobalOceanNotebooks/raw/master/OceanTransports/Streamfunction.png", width="250", style="border-radius:5px;", caption="Vector Potential"} \figure{path="https://github.com/JuliaClimate/GlobalOceanNotebooks/raw/master/OceanTransports/ScalarPotential.png", width="250", style="border-radius:5px;", caption="Scalar Potential"} 

\end{center}

\end{section}

\begin{section}{title="ClimateModels.jl notebooks",name="Models"}

**ClimateModels.jl** provides a uniform interface to climate models of varying complexity and completeness. Models that range from low dimensional to whole Earth System models can be run and/or analyzed via this framework. 

It also supports e.g. cloud computing workflows that start from previous model output available over the internet. Common file formats are supported. Version control, using _git_, is included to allow for workflow documentation and reproducibility.

`Examples / Running Models`

- [random walk model (0D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/RandomWalker.html) ➭ [download / url](https://gaelforget.github.io/ClimateModels.jl/dev/examples/RandomWalker.jl)
- [ShallowWaters.jl model (2D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/ShallowWaters.html) ➭ [download / url](https://gaelforget.github.io/ClimateModels.jl/dev/examples/ShallowWaters.jl)
- [Hector climate model (global)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Hector.html) ➭ [download / url](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Hector.jl)
- [SPEEDY atmosphere model (3D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Speedy.html) ➭ [download / url](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Speedy.jl)
- [MITgcm general circulation model (3D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/MITgcm.html) ➭ [download / url](https://gaelforget.github.io/ClimateModels.jl/dev/examples/MITgcm.jl)

`Examples / Replaying Outputs`

- [CMIP6 model output](https://gaelforget.github.io/ClimateModels.jl/dev/examples/CMIP6.html) ➭ [download / url](https://gaelforget.github.io/ClimateModels.jl/dev/examples/CMIP6.jl)
- [2021 climate report, fig1](notebook_01.html) ➭ [download / url](https://raw.githubusercontent.com/JuliaClimate/GlobalOceanNotebooks/master/IPCC/notebook_01.jl)
- [2021 climate report, fig2](notebook_02.html) ➭ [download / url](https://raw.githubusercontent.com/JuliaClimate/GlobalOceanNotebooks/master/IPCC/notebook_02.jl)
- [2021 climate report, fig3](notebook_03.html) ➭ [download / url](https://raw.githubusercontent.com/JuliaClimate/GlobalOceanNotebooks/master/IPCC/notebook_03.jl)
- [2021 climate report, fig4](notebook_04.html) ➭ [download / url](https://raw.githubusercontent.com/JuliaClimate/GlobalOceanNotebooks/master/IPCC/notebook_04.jl)
- [2021 climate report, fig5](notebook_05.html) ➭ [download / url](https://raw.githubusercontent.com/JuliaClimate/GlobalOceanNotebooks/master/IPCC/notebook_05.jl)

_IPCC, 2021: Summary for Policymakers. In: Climate Change 2021: The Physical Science Basis. Contribution of Working Group I to the Sixth Assessment Report of the Intergovernmental Panel on Climate Change [Masson-Delmotte, V., P. Zhai, A. Pirani, S. L. Connors, C. Péan, S. Berger, N. Caud, Y. Chen, L. Goldfarb, M. I. Gomis, M. Huang, K. Leitzell, E. Lonnoy, J.B.R. Matthews, T. K. Maycock, T. Waterfield, O. Yelekçi, R. Yu and B. Zhou (eds.)]. Cambridge University Press. In Press._

\end{section}

\begin{section}{title="Examples / Ocean Transports",name="Transports"}

- [transports](https://nbviewer.jupyter.org/github/JuliaClimate/GlobalOceanNotebooks/blob/master/OceanTransports/04_transports.ipynb) computes total ocean currents over latitude bands. It plots interpolated results over the Global Ocean.
- [streamfunction](https://nbviewer.jupyter.org/github/JuliaClimate/GlobalOceanNotebooks/blob/master/OceanTransports/05_streamfunction.ipynb) provides a synthetic view of ocean currents from above. It computes a horizontal streamfunction along with the other, divergent, transport component.
- [overturning](https://nbviewer.jupyter.org/github/JuliaClimate/GlobalOceanNotebooks/blob/master/OceanTransports/06_overturning.ipynb) computes meridional overturning circulation (the _M.O.C._; also sometimes described as _ocean conveyor belt_).
- [particles](https://nbviewer.jupyter.org/github/JuliaClimate/GlobalOceanNotebooks/blob/master/OceanTransports/07_particles.ipynb) tracks particles in the Global Ocean. It computes particle trajectories from gridded flow fields.

\end{section}

\begin{section}{title="IndividualDisplacements.jl notebooks",name="Particles"}

**IndividualDisplacements.jl** computes point displacements over a gridded domain. It is geared towards the analysis of Climate, Ocean, etc models (`Arakawa C-grids` are natively supported) and the simulation of material transports within the Earth System (e.g. plastics or planktons in the Ocean; dusts or chemicals in the Atmosphere). 

- [solid\_body\_rotation.ipynb](https://nbviewer.jupyter.org/github/JuliaClimate/IndividualDisplacements.jl/blob/gh-pages/dev/notebooks/solid_body_rotation.ipynb)
- [random\_flow\_field.ipynb](https://nbviewer.jupyter.org/github/JuliaClimate/IndividualDisplacements.jl/blob/gh-pages/dev/notebooks/random_flow_field.ipynb)
- [detailed\_look.ipynb](https://nbviewer.jupyter.org/github/JuliaClimate/IndividualDisplacements.jl/blob/gh-pages/dev/notebooks/detailed_look.ipynb)
- [particle\_cloud.ipynb](https://nbviewer.jupyter.org/github/JuliaClimate/IndividualDisplacements.jl/blob/gh-pages/dev/notebooks/particle_cloud.ipynb)
- [global\_ocean\_circulation.ipynb](https://nbviewer.jupyter.org/github/JuliaClimate/IndividualDisplacements.jl/blob/gh-pages/dev/notebooks/global_ocean_circulation.ipynb)
- [three\_dimensional\_ocean.ipynb](https://nbviewer.jupyter.org/github/JuliaClimate/IndividualDisplacements.jl/blob/gh-pages/dev/notebooks/three_dimensional_ocean.ipynb)

\end{section}

\begin{section}{title="MITgcmTools.jl notebooks",name="MITgcm"}

**MITgcmTools.jl** is a set of tools for running [MITgcm](https://mitgcm.readthedocs.io/en/latest/?badge=latest), analyzing its output, and/or modifying its inputs. A set of [Pluto.jl](https://github.com/fonsp/Pluto.jl) notebooks, which e.g. run `MITgcm` interactively, can be found below or via in [the docs](https://gaelforget.github.io/MITgcmTools.jl/dev).

`Examples / Running Models`
  
- [MITgcm_configurations.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/MITgcm_configurations.html) : explore MITgcm configurations and their parameters.
- [MITgcm_worklow.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/MITgcm_worklow.html) : build, setup, run, and plot for any standard configuration.
- [MITgcm_run.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/MITgcm_run.html) : a more detailed look into compiling and running the model.

`Examples / Analyzing Results`
  
- [HS94_animation.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/HS94_animation.html) : run `hs94.cs-32x32x5`, read output, interpolate, and animate map
- [HS94_particles.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/HS94_particles.html) : compute particle trajectories from `hs94.cs-32x32x5` output
- [HS94_Makie.jl](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/HS94_Makie.jl) : example using `Makie.jl` instead of `Plots.jl`
- [MITgcm\_scan\_output.jl](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/MITgcm_scan_output.jl) : scan `output.txt`, read grid, viz with `Makie.jl` 

\end{section}

\begin{section}{title="Examples / Data Structures",name="Data Structures"}

- [interpolation](https://nbviewer.jupyter.org/github/JuliaClimate/GlobalOceanNotebooks/blob/master/DataStructures/04_interpolation.ipynb) illustrates how the geo-spatial interpolation method in `MeshArrays.jl` works and can be used to e.g. produce global maps.
- [ZarrCloud](https://nbviewer.jupyter.org/github/JuliaClimate/GlobalOceanNotebooks/blob/master/DataStructures/05_ZarrCloud.ipynb) accesses climate model output hosted in the cloud, from the [CMIP6](https://bit.ly/2WiWmoh) archive, using `AWS.jl` and `Zarr.jl` via [ClimateModels.jl](https://gaelforget.github.io/ClimateModels.jl/dev/).
- [MeshArrays](https://nbviewer.jupyter.org/github/JuliaClimate/GlobalOceanNotebooks/blob/master/DataStructures/01_MeshArrays.ipynb)  illustrates the main data structures defined in [MeshArrays.jl](https://juliaclimate.github.io/MeshArrays.jl/stable/), data communication between neighboring subdomains, and application to transport modeling.
- [NCTiles](https://nbviewer.jupyter.org/github/JuliaClimate/GlobalOceanNotebooks/blob/master/DataStructures/03_nctiles.ipynb) converts binary data into meta-data-rich [NetCDF](https://en.wikipedia.org/wiki/NetCDF) files using [NCTiles.jl](https://gaelforget.github.io/NCTiles.jl/dev) for (1) a simple rectangular grid; (2) a tiled domain distributed over multiple files.

\end{section}

\begin{section}{title="Notes",name="Notes"}

- Each `.ipynb` notebook in this repository should be paired with a `.jl` file via `jupytext`
- To start an interactive version, e.g., [use this mybinder.org link](https://mybinder.org/v2/gh/JuliaClimate/GlobalOceanNotebooks/master)
- Data downloaded into the `inputs/` folder can safely be removed afterwards
- Efficiency can be improved in various places or simply through parallelization.
- Please use the [repository issue tracker](https://guides.github.com/features/issues/) for queries, bug reports, new contributions, etc.
- Below are additional notebooks that further illustrate specific packages.

\end{section}
