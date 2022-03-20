
\begin{section}{title="Overview",name="Overview"}

\label{introduction}

[![Binder](https://mybinder.org/badge_logo.svg)](https://gesis.mybinder.org/v2/gh/JuliaClimate/Notebooks/HEAD?urlpath=lab)
[![DOI](https://zenodo.org/badge/147266407.svg)](https://zenodo.org/badge/latestdoi/147266407)

This page presents a series of [Julia](https://julialang.org) notebooks (see [Pluto.jl](https://plutojl.org)) that demonstrate [JuliaClimate](https://github.com/JuliaClimate/) packages working in concert together and within the broader Julia package ecosystem. 
Users can replay the notebooks on a local computer or in the cloud (see [How-To](#howto) and [cloud](#cloud) for directions).

\end{section}

\begin{section}{title="Contents",name="Contents"}

\label{contents}

The notebooks mostly come from the `examples` section of a Julia package.

- Data Products / [OceanStateEstimation.jl](#ocean-state-estimation) examples
- Data Products / [OceanRobots.jl](#ocean-robots) examples
- Models / [ClimateModels.jl](#climate-models) examples
- Models / [MITgcmTools.jl](#mitgcm-tools) examples
- [MeshArrays.jl](#mesh-arrays) examples
- [IndividualDisplacements.jl](#individual-displacements) examples
- [Files & NetCDF](#files)
- [Workshops](#workshop)

The [User Directions](#directions) section is for those interested in running notebooks themselves.

- [How-To](#howto)
- [Cloud Services](#cloud)

**Packages Overview**

Usage of gridded data sets is demonstrated in the `OceanStateEstimation.jl` notebooks. `OceanRobots.jl` in turn deals with sparse data collected in situ by diverse methods. The examples cover common file formats and protocols for accessing data. 

The `ClimateModels.jl` package provides an interface to models often used in climate science. The examples either run models and generate new output, or replay model output generated earlier (e.g. from CMIP6 or the 2021 IPCC report). Additional examples for the [MIT general circulation model](https://mitgcm.readthedocs.io/en/latest/) are provided in `MITgcmTools.jl`.

An important requirement in climate science is to derive transports using native model grid output to e.g. precisely close energy budgets. This is one of the applications of `MeshArrays.jl` -- the analysis of global transports derived from gridded model output. Topics covered via `MeshArrays.jl` also include interpolation and geography.

`IndividualDisplacements.jl` extends this approach by providing a [particle tracking](https://en.wikipedia.org/wiki/Lagrangian_and_Eulerian_specification_of_the_flow_field) framework that readily operates on climate model `C-grids` using `MeshArrays.jl`. 
Examples that let you access and explore ocean data products are provided in `OceanRobots.jl` and `OceanStateEstimation.jl`. The `More` section touches on topics such as files (incl. NetCDF and Zarr), visualization, cloud services, and user directions.

**Visual Examples**

\label{sample-viz}

Here are images generated using the Julia packages and notebooks listed in this webpage. The maps, histograms, and other graphs are made with [Makie.jl](https://makie.juliaplots.org/stable/) and [Plots.jl](http://docs.juliaplots.org/latest/). Other popular plotting libraries include [Gnuplot.jl](https://github.com/gcalderone/Gnuplot.jl), [PyPlot.jl](https://github.com/JuliaPy/PyPlot.jl), [PlotlyJS.jl](http://juliaplots.org/PlotlyJS.jl/stable/), [GR.jl](https://github.com/jheinen/GR.jl), and [UnicodePlots.jl](https://github.com/JuliaPlots/UnicodePlots.jl).


\begin{center}

\figure{path="https://user-images.githubusercontent.com/20276764/143275888-ff02f149-225f-45ac-ae5e-1049e15ab215.png", width="150", style="border-radius:5px;", caption="IPCC report fig 1b"} \figure{path="https://user-images.githubusercontent.com/20276764/135203143-ae838319-1a63-4ffe-8f08-1055174b79aa.png", width="150", style="border-radius:5px;", caption="IPCC report fig 2"}
\figure{path="https://user-images.githubusercontent.com/20276764/135203198-a5e2dc49-baee-4d13-a113-5433c074bbff.png", width="140", style="border-radius:5px;", caption="IPCC report fig 3"} \figure{path="https://user-images.githubusercontent.com/20276764/135203214-ce6caece-13d1-49f3-9a70-7fa63d810e9c.png", width="160", style="border-radius:5px;", caption="IPCC report fig 5"}

\figure{path="https://github.com/JuliaClimate/Notebooks/raw/master/page/figures/MOC.png", width="150", style="border-radius:5px;", caption="Meridional Overturning Streamfunction"} \figure{path="https://user-images.githubusercontent.com/20276764/119210600-0dc9ba00-ba7b-11eb-96c1-e0f5dc75c838.png", width="150", style="border-radius:5px;", caption="Particle Tracking"} 
\figure{path="https://github.com/JuliaClimate/Notebooks/raw/master/page/figures/Streamfunction.png", width="150", style="border-radius:5px;", caption="Vector Potential"} \figure{path="https://github.com/JuliaClimate/Notebooks/raw/master/page/figures/ScalarPotential.png", width="150", style="border-radius:5px;", caption="Scalar Potential"} 

\end{center}

\end{section}

\begin{section}{title="Data Products",name="Data"}

The [climate models](#climate-models) section provides examples where climate model output is retrieved from the web. These include examples that read from NetCDF, Zarr, and CSV files (see [CMIP6 model output](https://gaelforget.github.io/ClimateModels.jl/dev/examples/CMIP6.html) , [2021 climate report](https://gaelforget.github.io/ClimateModels.jl/dev/examples/IPCC.html) ). 

In this section, we provide additional representative examples that cover common file formats and access protocols (http, ftp, opendap, thredds). Use cases are taken from ocean sciences -- `OceanRobots.jl` for discrete samples and `OceanStateEstimation.jl` for gridded fields. 

[OceanStateEstimation.jl](https://github.com/gaelforget/OceanStateEstimation.jl) : package currently focused on serving and deriving climatologies from ocean state estimates.

\label{ocean-state-estimation}

- [ECCO\_standard\_plots.jl](https://gaelforget.github.io/OceanStateEstimation.jl/dev/examples/ECCO_standard_plots.html) ([notebook url](https://raw.githubusercontent.com/gaelforget/OceanStateEstimation.jl/master/examples/ECCO/ECCO_standard_plots.jl)) : visualize and compare NASA ocean state estimates ([ECCO reanalysis](https://ecco-group.org))
- [CBIOMES\_climatology\_plot.jll](https://gaelforget.github.io/OceanStateEstimation.jl/dev/examples/CBIOMES_climatology_plot.html) ([notebook url](https://raw.githubusercontent.com/gaelforget/OceanStateEstimation.jl/master/examples/CBIOMES/CBIOMES_climatology_plot.jl)) : climatology maps that describe marine ecosystems ([CBIOMES program](https://cbiomes.org))

[OceanRobots.jl](https://github.com/gaelforget/OceanRobots.jl) : Simulation, processing, and analysis of data generated by scientific robots in the Ocean. These include profiling floats (Argo), drifters (GDP), and moorings for examples.

\label{ocean-robots}

- [example\_NWP\_NOAA.jl](https://gaelforget.github.io/OceanRobots.jl/dev/examples/example_NWP_NOAA.html) ([notebook url](https://raw.githubusercontent.com/gaelforget/OceanRobots.jl/master/examples/example_NWP_NOAA.jl)) displays [NOAA station](https://www.ndbc.noaa.gov/) data
- [example\_WHOTS.jl](https://gaelforget.github.io/OceanRobots.jl/dev/examples/example_WHOTS.html) ([notebook url](https://raw.githubusercontent.com/gaelforget/OceanRobots.jl/master/examples/example_WHOTS.jl)) displays [WHOTS mooring](http://www.soest.hawaii.edu/whots/wh_data.html) data
- [example\_GDP.jl](https://gaelforget.github.io/OceanRobots.jl/dev/examples/example_GDP.html) ([notebook url](https://raw.githubusercontent.com/gaelforget/OceanRobots.jl/master/examples/example_GDP.jl)) displays a [drifter](https://www.aoml.noaa.gov/phod/gdp/hourly_data.php) time series
- [example\_Argo.jl](https://gaelforget.github.io/OceanRobots.jl/dev/examples/example_Argo.html) ([notebook url](https://raw.githubusercontent.com/gaelforget/OceanRobots.jl/master/examples/example_Argo.jl)) shows data from an [Argo](https://argo.ucsd.edu) profiling float


\end{section}

\begin{section}{title="ClimateModels.jl",name="Models"}

\label{climate-models}

[ClimateModels.jl](https://gaelforget.github.io/ClimateModels.jl/dev/) provides a uniform interface to climate models of varying complexity and completeness. Models that range from low dimensional to whole Earth System models can be run and/or analyzed via this framework. The package also illustrates cloud computing workflows that start from previous model output accessed from the web. Common file formats are supported. Version control, using _git_, is included to allow for workflow documentation and reproducibility.

`Replaying Outputs`

- [CMIP6 model output](https://gaelforget.github.io/ClimateModels.jl/dev/examples/CMIP6.html) ➭ [notebook url](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/CMIP6.jl)
- [2021 climate report](https://gaelforget.github.io/ClimateModels.jl/dev/examples/IPCC.html) ➭ [notebook url](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/IPCC.jl)

`Running Models`

- [Random walk model (0D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/RandomWalker.html) ➭ [notebook url](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/RandomWalker.jl)
- [ShallowWaters.jl model (2D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/ShallowWaters.html) ➭ [notebook url](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/ShallowWaters.jl)
- [Oceananigans.jl model (3D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Oceananigans.html) ➭ [notebook url](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/Oceananigans.jl)
- [Hector climate model (global)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Hector.html) ➭ [notebook url](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/Hector.jl)
- [FaIR	 climate model (global)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/FaIR.html) ➭ [notebook url](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/FaIR.jl)
- [SPEEDY atmosphere model (3D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Speedy.html) ➭ [notebook url](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/Speedy.jl)
- [MITgcm general circulation model (3D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/MITgcm.html) ➭ [notebook url](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/MITgcm.jl)

`MIT general circulation model`

\label{mitgcm-tools}

\\

[MITgcmTools.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/) is a set of tools for running [MITgcm](https://mitgcm.readthedocs.io/en/latest/?badge=latest), analyzing its output, and so on. The `examples` folder provides a series of [Pluto.jl](https://github.com/fonsp/Pluto.jl) notebooks, which can be found in the package documentation. The examples run `MITgcm` interactively via the `ClimateModels.jl` interface, rely on `MeshArrays.jl` for visualizing results, use `IndividualDisplacements.jl` to derive material pathways, etc.

- [MITgcm_configurations.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/MITgcm_configurations.html) ([notebook url](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/MITgcm_configurations.jl)); explore MITgcm configurations and their parameters.
- [MITgcm\_scan\_output.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/MITgcm_scan_output.html) ([notebook url](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/MITgcm_scan_output.jl)) : scan run directory, standard output, read grid files, and visualize. 
- [MITgcm_run.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/MITgcm_run.html) ([notebook url](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/MITgcm_run.jl)) : a detailed look into compiling and running the model.
- [MITgcm_worklow.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/MITgcm_worklow.html) ([notebook url](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/MITgcm_worklow.jl)): build, setup, run, and plot for a chosen standard MITgcm configuration.
- [HS94_animation.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/HS94_animation.html) ([notebook url](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/HS94_animation.jl)) : run simple Atmosphere configuration, read output, interpolate, and plot maps.
- [HS94_particles.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/HS94_particles.html) ([notebook url](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/HS94_particles.jl)) : compute particle trajectories from model output generated in `HS94_animation.jl`.
- [HS94_Makie.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/HS94_Makie.html) ([notebook url](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/HS94_Makie.jl)) : using `Makie.jl` instead of `Plots.jl`

\end{section}

\begin{section}{title="MeshArrays.jl",name="Arrays"}

\label{mesh-arrays}

[MeshArrays.jl](https://juliaclimate.github.io/MeshArrays.jl/dev) defines an array type that can contain / organize / distribute collections of inter-connected arrays as generally done in climate models. These data structures can be used to simulate variables of the climate system such as [particles](https://doi.org/10.21105/joss.02813) and [transports](https://doi.org/10.1038/s41561-019-0333-7).

- [Geography](https://juliaclimate.github.io/MeshArrays.jl/dev/tutorials/geography.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/MeshArrays.jl/master/examples/geography.jl)) tutorial : deals with interpolation, projection, and visualization of gridded fields in geographic coordinates.
- [Vector Fields](https://juliaclimate.github.io/MeshArrays.jl/dev/tutorials/vectors.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/MeshArrays.jl/master/examples/vectors.jl)) tutorial : covers the computation of global transports, streamfunctions, potentials, gradients, curls, and more.
- [Basics](https://juliaclimate.github.io/MeshArrays.jl/dev/tutorials/basics.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/MeshArrays.jl/master/examples/basics.jl)) tutorial : illustrates how the MeshArrays.jl data structures let us write generic code readily applicable to whole families of grids.

\end{section}

\begin{section}{title="IndividualDisplacements.jl",name="Points"}

\label{individual-displacements}

[IndividualDisplacements.jl](https://juliaclimate.github.io/IndividualDisplacements.jl/dev/) computes point displacements over a gridded domain. It is geared towards the analysis of Climate, Ocean, etc models (`Arakawa C-grids` are natively supported) and the simulation of material transports within the Earth System (e.g. plastics or planktons in the Ocean; dusts or chemicals in the Atmosphere). 

- [Simple Two-Dimensional Flow](https://juliaclimate.github.io/IndividualDisplacements.jl/dev/examples/random_flow_field.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/IndividualDisplacements.jl/master/examples/basics/random_flow_field.jl))
- [Simple Three-Dimensional Flow](https://juliaclimate.github.io/IndividualDisplacements.jl/dev/examples/solid_body_rotation.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/IndividualDisplacements.jl/master/examples/basics/solid_body_rotation.jl))
- [Global Ocean Circulation (2D)](https://juliaclimate.github.io/IndividualDisplacements.jl/dev/examples/global_ocean_circulation.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/IndividualDisplacements.jl/master/examples/worldwide/global_ocean_circulation.jl))
- [Global Ocean Circulation (3D)](https://juliaclimate.github.io/IndividualDisplacements.jl/dev/examples/three_dimensional_ocean.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/IndividualDisplacements.jl/master/examples/worldwide/three_dimensional_ocean.jl))

\end{section}

\begin{section}{title="More",name="More"}

\label{more}

**Files & NetCDF**

\label{files}

- [NetCDF\_basics.jl](NetCDF_basics.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/Notebooks/master/tutorials/NetCDF_basics.jl)) is a brief tutorial that opens a netCDF file using [NCDatasets.jl](https://alexander-barth.github.io/NCDatasets.jl/latest/) and plots a 2D slice as a heatmap using [Makie.jl](https://makie.juliaplots.org/stable/).
- [NetCDF\_packages.jl](NetCDF_packages.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/Notebooks/master/tutorials/NetCDF_packages.jl)) reviews packages for ingesting NetCDF into various data structures; including [ClimateBase.jl](https://juliaclimate.github.io/ClimateBase.jl/dev/) and [ClimateTools.jl](https://juliaclimate.github.io/ClimateTools.jl/dev/).
- [NetCDF\_advanced.jl](NetCDF_advanced.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/Notebooks/master/tutorials/NetCDF_advanced.jl)) uses a large file to look at performance.

Other packages : [NetCDF.jl](https://juliageo.github.io/NetCDF.jl/dev) provides high-level and medium-level interfaces for writing and reading netcdf files. [Zarr.jl](https://juliaio.github.io/Zarr.jl/latest/) supports reading and Writing Zarr Datasets from Julia. [NCTiles.jl](https://gaelforget.github.io/NCTiles.jl/dev) converts binary data into meta-data-rich [NetCDF](https://en.wikipedia.org/wiki/NetCDF) files for (1) a simple rectangular grid; (2) a tiled domain distributed over multiple files.

**Workshops**

\label{workshop}

The JuliaCon 2021 Workshop on `Modeling Marine Ecosystems At Multiple Scales Using Julia` was based on notebooks listed below. Additional detail is available in [this repository](https://github.com/JuliaOcean/MarineEcosystemsJuliaCon2021.jl).

- [AIBECS](https://juliaocean.github.io/MarineEcosystemsJuliaCon2021.jl/dev/AIBECSExample.html) ([notebook url](https://raw.githubusercontent.com/JuliaOcean/MarineEcosystemsJuliaCon2021.jl/main/src/AIBECSExample.jl)) : global steady-state biogeochemistry and gridded transport models that run fast for long time scales (centuries or even millennia).
- [PlanktonIndividuals](https://juliaocean.github.io/MarineEcosystemsJuliaCon2021.jl/dev/PlanktonIndividualExample.html) ([notebook url](https://raw.githubusercontent.com/JuliaOcean/MarineEcosystemsJuliaCon2021.jl/main/src/PlanktonIndividualExample.jl))  local to global agent-based model, particularly suited to study microbial communities, plankton physiology, and nutrient cycles.
- [MITgcm global biogeo](https://juliaocean.github.io/MarineEcosystemsJuliaCon2021.jl/dev/MITgcm_tutorial_global_oce_biogeo.html) ([notebook url](https://raw.githubusercontent.com/JuliaOcean/MarineEcosystemsJuliaCon2021.jl/main/src/MITgcm_tutorial_global_oce_biogeo.jl)) : interface to full-featured, Fortran-based, general circulation model and its output (transports, chemistry, ecology, ocean, sea-ice, atmosphere, and more).
- [IndividualDisplacements](https://juliaocean.github.io/MarineEcosystemsJuliaCon2021.jl/dev/IndividualDisplacementsExample.html) ([notebook url](https://raw.githubusercontent.com/JuliaOcean/MarineEcosystemsJuliaCon2021.jl/main/src/IndividualDisplacementsExample.jl)) : local to global particle tracking, for simulating dispersion, connectivity, transports in the ocean or atmosphere, etc.

\end{section}

\begin{section}{title="User Directions",name="Directions"}

\label{directions}

**How-To**

\label{howto}

To start an interactive version of a notebook, on a local computer or in the cloud, start `Pluto.jl` and then : 

- copy `notebook url` from webpage
- paste `notebook url` into Pluto
- `open` and wait for notebook to boot up
- interact with the reactive notebook

~~~
<br/>
~~~

Video demonstration (3.5 min) :

@@im-50
[![Video Tutorial](https://user-images.githubusercontent.com/20276764/158916468-3f58fd83-e0a7-4650-b4b6-3612e4a4e429.png)](https://youtu.be/mZevMagHatc)
@@

Step by step summary :

\begin{center}

@@im-20
[![Step 1](https://user-images.githubusercontent.com/20276764/156822528-fece5ce5-ae94-4d93-a2fe-7ff007a0fb13.png)](https://user-images.githubusercontent.com/20276764/156822528-fece5ce5-ae94-4d93-a2fe-7ff007a0fb13.png) [![Step 2](https://user-images.githubusercontent.com/20276764/156822529-6a58db73-c25e-4ffc-b768-5d4e9ee5e342.png)](https://user-images.githubusercontent.com/20276764/156822529-6a58db73-c25e-4ffc-b768-5d4e9ee5e342.png) [![Step 3](https://user-images.githubusercontent.com/20276764/156822530-f4e28e5f-0622-4f28-9906-3291dce99662.png)](https://user-images.githubusercontent.com/20276764/156822530-f4e28e5f-0622-4f28-9906-3291dce99662.png) [![Step 4](https://user-images.githubusercontent.com/20276764/156822531-b3556afb-75f5-43cb-80b2-43e401966140.png)](https://user-images.githubusercontent.com/20276764/156822531-b3556afb-75f5-43cb-80b2-43e401966140.png)
@@

\end{center}

~~~
<br/>
~~~

To start [Pluto.jl](https://github.com/fonsp/Pluto.jl/wiki) from `julia` one calls `Pluto.run()`. Alternatively, one can specify the notebook via the `Pluto.run` command. 

```
using Pluto, Downloads
url="https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/IPCC.jl"
Pluto.run(notebook=Downloads.download(url))
```

To download all notebooks listed on the webpage, and use the local copy (`Notebooks/NetCDF_basics.jl`)instead of URLs, proceed as follows. 

```
git clone https://github.com/JuliaClimate/Notebooks
include("Notebooks/tutorials/list_notebooks.jl")
notebooks=list_notebooks()

download_notebooks("Notebooks/jl",notebooks)
cd("Notebooks/jl")

using Pluto; 
Pluto.run(notebook="Notebooks/NetCDF_basics.jl")
```

~~~
<br/>
~~~

Please use the [repository issue tracker](https://guides.github.com/features/issues/) ([this one](https://github.com/JuliaClimate/Notebooks/issues)) for queries, bug reports, new contributions, etc.

~~~
<br/>
~~~

**Open Cloud Services**

\label{cloud}

We are very grateful to the [BinderHub Federation](https://mybinder.readthedocs.io/en/latest/about/federation.html) for deploying public BinderHubs to serve the community. Visiting [mybinder.org](https://mybinder.org) will randomly redirect you to one of the BinderHubs selected at random. 

The shorcuts provided below are configured for the `JuliaClimate/Notebooks` repository more specifically. 

[![Binder](https://mybinder.org/badge_logo.svg)](https://gesis.mybinder.org/v2/gh/JuliaClimate/Notebooks/HEAD?urlpath=lab)

- [gesis.mybinder.org](https://gesis.mybinder.org/v2/gh/JuliaClimate/Notebooks/HEAD?urlpath=lab)
- [gke.mybinder.org](https://gke.mybinder.org/v2/gh/JuliaClimate/Notebooks/HEAD?urlpath=lab)
- [ovh.mybinder.org](https://ovh.mybinder.org/v2/gh/JuliaClimate/Notebooks/HEAD?urlpath=lab)
- [turing.mybinder.org](https://turing.mybinder.org/v2/gh/JuliaClimate/Notebooks/HEAD?urlpath=lab)

~~~
<br/>
~~~

Step by step summary :

\begin{center}

@@im-20
[![Step 1](https://user-images.githubusercontent.com/20276764/156822594-9dcb6899-e3f5-45d3-a595-dc89d97aafa8.png)](https://user-images.githubusercontent.com/20276764/156822594-9dcb6899-e3f5-45d3-a595-dc89d97aafa8.png) [![Step 2](https://user-images.githubusercontent.com/20276764/156822596-b84d806f-f6cb-4d13-af81-2f8b52f42237.png)](https://user-images.githubusercontent.com/20276764/156822596-b84d806f-f6cb-4d13-af81-2f8b52f42237.png) [![Step 3](https://user-images.githubusercontent.com/20276764/156822597-2bf1c0f7-aafe-49bd-863a-ff5be7658ca3.png)](https://user-images.githubusercontent.com/20276764/156822597-2bf1c0f7-aafe-49bd-863a-ff5be7658ca3.png)
@@

\end{center}

~~~
<br/>
~~~

A few notes :

- For repeated use it is suggested that you run the notebooks on a local computer rather than in the free cloud if possible. Not only will this probably be faster than on `mybinder` but it will also save funds that allow `mybinder` to provide these shared cloud services to the community without charge.
- Memory limitations can occur but the resources provided by `mybinder` generally suffice to run the notebooks without excessive latency. For the `mybinder` case, notebooks have been downloaded into the `jl` folder to facilitate navigation within `Pluto`. 
- In our `mybinder` configuration, a list of the notebooks can be obtained as follows.

```
include("tutorials/list_notebooks.jl")
notebooks=list_notebooks()
```

\end{section}

