
\begin{section}{title="Overview",name="Overview"}

\label{introduction}

[Julia](https://julialang.org) notebooks (using [Jupyter](https://jupyter.org) or [Pluto](https://plutojl.org)) that illustrate some of the [JuliaClimate](https://github.com/JuliaClimate/) packages working in concert and within the broader ecosystem. 

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/JuliaClimate/GlobalOceanNotebooks/master)
[![DOI](https://zenodo.org/badge/147266407.svg)](https://zenodo.org/badge/latestdoi/147266407)

The **ClimateModels.jl** package provides an interface to models often used in climate science. Included notebooks provide examples that either run models and generate new output, or replay model output generated earlier (e.g. from CMIP6 or the 2021 IPCC report).

An important requirement in climate science is to derive transports using native model grid output to e.g. precisely close energy budgets. This is one of the applications of **MeshArrays.jl** -- the computation and analysis of global ocean transports derived accurately from gridded model output. 

**IndividualDisplacements.jl** extends this approach by providing a [particle tracking](https://en.wikipedia.org/wiki/Lagrangian_and_Eulerian_specification_of_the_flow_field) framework that readily operates on climate model `C-grids` (see **MeshArrays.jl**). In the examples, model output from the [MITgcm](https://mitgcm.readthedocs.io/en/latest/) are loaded using functions provided by **MITgcmTools.jl**.

The final section further address the handling of files (incl. NetCDF and Zarr files), vizualization, and other common tasks in climate science.

- [Vizualization Examples](#sample-viz)
- [MeshArrays.jl](#mesh-arrays)
- [IndividualDisplacements.jl](#individual-displacements)
- [ClimateModels.jl](#climate-models)
- [MITgcmTools.jl](#mitgcm-tools)
- [Files, Viz, and More](#files-viz-more)

\end{section}

\begin{section}{title="Vizualization Examples",name="Vizualizations"}

\label{sample-viz}

The plots below are examples generated using the Julia packages listed in the [introduction](#introduction).

\begin{center}

\figure{path="https://github.com/JuliaClimate/GlobalOceanNotebooks/raw/master/OceanTransports/MOC.png", width="250", style="border-radius:5px;", caption="Meridional Overturning Streamfunction"} \figure{path="https://user-images.githubusercontent.com/20276764/119210600-0dc9ba00-ba7b-11eb-96c1-e0f5dc75c838.png", width="250", style="border-radius:5px;", caption="Particle Tracking"} 

\figure{path="https://user-images.githubusercontent.com/20276764/135203125-e663713e-48c9-42e0-bbd7-bd4ba222b70a.png", width="250", style="border-radius:5px;", caption="IPCC report fig 1b"} \figure{path="https://user-images.githubusercontent.com/20276764/135203143-ae838319-1a63-4ffe-8f08-1055174b79aa.png", width="250", style="border-radius:5px;", caption="IPCC report fig 2"}

\figure{path="https://user-images.githubusercontent.com/20276764/135203198-a5e2dc49-baee-4d13-a113-5433c074bbff.png", width="250", style="border-radius:5px;", caption="IPCC report fig 3"} \figure{path="https://user-images.githubusercontent.com/20276764/135203214-ce6caece-13d1-49f3-9a70-7fa63d810e9c.png", width="250", style="border-radius:5px;", caption="IPCC report fig 5"}

\figure{path="https://github.com/JuliaClimate/GlobalOceanNotebooks/raw/master/OceanTransports/Streamfunction.png", width="250", style="border-radius:5px;", caption="Vector Potential"} \figure{path="https://github.com/JuliaClimate/GlobalOceanNotebooks/raw/master/OceanTransports/ScalarPotential.png", width="250", style="border-radius:5px;", caption="Scalar Potential"} 

\end{center}

\end{section}

\begin{section}{title="ClimateModels.jl",name="Models"}

\label{climate-models}

[ClimateModels.jl](https://gaelforget.github.io/ClimateModels.jl/dev/) provides a uniform interface to climate models of varying complexity and completeness. Models that range from low dimensional to whole Earth System models can be run and/or analyzed via this framework. It also supports e.g. cloud computing workflows that start from previous model output available over the internet. Common file formats are supported. Version control, using _git_, is included to allow for workflow documentation and reproducibility.

`Examples / Running Models`

- [Random walk model (0D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/RandomWalker.html) ➭ [code link](https://gaelforget.github.io/ClimateModels.jl/dev/examples/RandomWalker.jl)
- [ShallowWaters.jl model (2D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/ShallowWaters.html) ➭ [code link](https://gaelforget.github.io/ClimateModels.jl/dev/examples/ShallowWaters.jl)
- [Hector climate model (global)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Hector.html) ➭ [code link](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Hector.jl)
- [FaIR	 climate model (global)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/FaIR.html) ➭ [code link](https://gaelforget.github.io/ClimateModels.jl/dev/examples/FaIR.jl)
- [SPEEDY atmosphere model (3D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Speedy.html) ➭ [code link](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Speedy.jl)
- [MITgcm general circulation model (3D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/MITgcm.html) ➭ [code link](https://gaelforget.github.io/ClimateModels.jl/dev/examples/MITgcm.jl)

`Examples / Replaying Outputs`

- [CMIP6 model output](https://gaelforget.github.io/ClimateModels.jl/dev/examples/CMIP6.html) ➭ [code link](https://gaelforget.github.io/ClimateModels.jl/dev/examples/CMIP6.jl)
- [2021 climate report](https://gaelforget.github.io/ClimateModels.jl/dev/examples/IPCC.html) ➭ [code link](https://gaelforget.github.io/ClimateModels.jl/dev/examples/IPCC.jl)

\end{section}

\begin{section}{title="MeshArrays.jl",name="Arrays"}

\label{mesh-arrays}

[MeshArrays.jl](https://juliaclimate.github.io/MeshArrays.jl/dev) defines an array type that can contain / organize / distribute collections of inter-connected arrays as generally done in climate models. These data structures can be used to simulate variables of the climate system such as [particles](https://doi.org/10.21105/joss.02813) and [transports](https://doi.org/10.1038/s41561-019-0333-7).

- [Geography](https://juliaclimate.github.io/MeshArrays.jl/dev/tutorials/vectors.html) ([code link](https://raw.githubusercontent.com/JuliaClimate/MeshArrays.jl/master/examples/geography.jl)) tutorial : deals with interpolation, projection, and vizualization of gridded fields in geographic coordinates.
- [Vector Fields](https://juliaclimate.github.io/MeshArrays.jl/dev/tutorials/vectors.html) ([code link](https://raw.githubusercontent.com/JuliaClimate/MeshArrays.jl/master/examples/vectors.jl)) tutorial : covers the computation of global transports, streamfunctions, potentials, gradients, curls, and more.
- [Basics](https://juliaclimate.github.io/MeshArrays.jl/dev/tutorials/basics.html) ([code link](https://raw.githubusercontent.com/JuliaClimate/MeshArrays.jl/master/examples/basics.jl)) tutorial : illustrates how the MeshArrays.jl data structures let us write generic code readily applicable to whole families of grids.

\end{section}

\begin{section}{title="IndividualDisplacements.jl",name="Particles"}

\label{individual-displacements}

[IndividualDisplacements.jl](https://juliaclimate.github.io/IndividualDisplacements.jl/dev/) computes point displacements over a gridded domain. It is geared towards the analysis of Climate, Ocean, etc models (`Arakawa C-grids` are natively supported) and the simulation of material transports within the Earth System (e.g. plastics or planktons in the Ocean; dusts or chemicals in the Atmosphere). 

- [Simple Two-Dimensional Flow](https://juliaclimate.github.io/IndividualDisplacements.jl/dev/examples/random_flow_field.html) ([code link](https://github.com/JuliaClimate/IndividualDisplacements.jl/blob/master/examples/basics/random_flow_field.jl))
- [Simple Three-Dimensional Flow](https://juliaclimate.github.io/IndividualDisplacements.jl/dev/examples/solid_body_rotation.html) ([code link](https://github.com/JuliaClimate/IndividualDisplacements.jl/blob/master/examples/basics/solid_body_rotation.jl))
- [Global Ocean Circulation (2D)](https://juliaclimate.github.io/IndividualDisplacements.jl/dev/examples/global_ocean_circulation.html) ([code link](https://github.com/JuliaClimate/IndividualDisplacements.jl/blob/master/examples/basics/global_ocean_circulation.jl))
- [Global Ocean Circulation (3D)](https://juliaclimate.github.io/IndividualDisplacements.jl/dev/examples/three_dimensional_ocean.html) ([code link](https://github.com/JuliaClimate/IndividualDisplacements.jl/blob/master/examples/basics/three_dimensional_ocean.jl))

\end{section}

\begin{section}{title="MITgcmTools.jl",name="MITgcm"}

\label{mitgcm-tools}

[MITgcmTools.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/) is a set of tools for running [MITgcm](https://mitgcm.readthedocs.io/en/latest/?badge=latest), analyzing its output, and/or modifying its inputs. The package documentation provides a series of [Pluto.jl](https://github.com/fonsp/Pluto.jl) notebooks, which e.g. run `MITgcm` interactively via the `ClimateModels.jl` interface, rely on `MeshArrays.jl` for vizualizing results, or use `IndividualDisplacements.jl` to derive material pathways.

- [MITgcm_configurations.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/MITgcm_configurations.html) ([code link](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/MITgcm_configurations.jl)); explore MITgcm configurations and their parameters.
- [MITgcm\_scan\_output.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/MITgcm_scan_output.html) ([code link](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/MITgcm_scan_output.jl)) : scan run directory, standard output, read grid files, and vizualize. 
- [MITgcm_run.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/MITgcm_run.html) ([code link](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/MITgcm_run.jl)) : a detailed look into compiling and running the model.
- [MITgcm_worklow.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/MITgcm_worklow.html) ([code link](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/MITgcm_worklow.jl)): build, setup, run, and plot for a chosen standard MITgcm configuration.
- [HS94_animation.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/HS94_animation.html) ([code link](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/HS94_animation.jl)) : run `hs94.cs-32x32x5` configuration, read output, interpolate, and plot maps.
- [HS94_particles.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/HS94_particles.html) ([code link](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/HS94_particles.jl)) : compute particle trajectories from `hs94.cs-32x32x5` output generated earlier.
- [HS94_Makie.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/HS94_Makie.html) ([code link](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/HS94_Makie.jl)) : using `Makie.jl` instead of `Plots.jl`

\end{section}

\begin{section}{title="Files, Viz, and More",name="More"}

\label{files-viz-more}

- `examples/VizNc.jl` opens a netCDF file using `NCDatasets.jl` and plots one data set slice as a heatmap using `Makie.jl`.
- [NCTiles.jl](https://gaelforget.github.io/NCTiles.jl/dev) converts binary data into meta-data-rich [NetCDF](https://en.wikipedia.org/wiki/NetCDF) files for (1) a simple rectangular grid; (2) a tiled domain distributed over multiple files.
- To start an interactive version, e.g., [use this mybinder.org link](https://mybinder.org/v2/gh/JuliaClimate/GlobalOceanNotebooks/master), open `Pluto.jl`, and paste a `code link` from above. This should work for most notebooks but we should note that `mybinder.org` does not offer enough memory to run all of the notebooks.
- Please use the [repository issue tracker](https://guides.github.com/features/issues/) ([this one](https://github.com/JuliaClimate/GlobalOceanNotebooks/issues)) for queries, bug reports, new contributions, etc.

\end{section}
