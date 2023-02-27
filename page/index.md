
\begin{section}{}

\label{introduction}

The listed notebooks highlight [JuliaClimate](https://github.com/JuliaClimate/) packages used within the broader [Julia](https://julialang.org) package ecosystem. To replay the [Pluto notebooks](https://plutojl.org) on your computer or in the cloud, see [User Directions](#directions). For visualization examples from the notebooks, see [visualization](#sample-viz).

~~~
<br/>
~~~

[![Website shields.io](https://img.shields.io/website-up-down-green-red/http/JuliaClimate.github.io/Notebooks)](https://JuliaClimate.github.io/Notebooks/)
[![Binder](https://mybinder.org/badge_logo.svg)](https://gesis.mybinder.org/v2/gh/JuliaClimate/Notebooks/HEAD?urlpath=lab)
[![DOI](https://zenodo.org/badge/147266407.svg)](https://zenodo.org/badge/latestdoi/147266407)

\end{section}

\begin{section}{title="Data Sets",name="Data"}

\label{datasets}

\lead{Climate Change}

Let's start by plotting important aspects of climate change like global warming and sea level rise. The notebooks use model projections and data stored in [various file formats](#files).

- [CMIP climate models](https://gaelforget.github.io/ClimateModels.jl/dev/examples/CMIP6.html) ([notebook url](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/CMIP6.jl)) : access climate model output from CMIP6 to compute temperature time series and maps.
- [IPCC climate report](https://gaelforget.github.io/ClimateModels.jl/dev/examples/IPCC.html) ([notebook url](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/IPCC.jl)) : reproduce figures from _Climate Change 2021, The Physical Science Basis, Summary for Policymakers_.
- [NASA Sea Level](https://JuliaOcean.github.io/OceanStateEstimation.jl/dev/examples/NSLCT_notebook.html) ([notebook url](https://raw.githubusercontent.com/JuliaOcean/OceanStateEstimation.jl/master/examples/NSLCT/NSLCT_notebook.jl)) : explore changes in sea level over the Globe using NASA data and estimates.

\lead{Gridded Data}

Gridded data can be read from files and written to files in [various formats](#files). NetCDF and GeoTIFF are two common examples. Gridded data may include climatologies, reanalyses, or gridded satellite data products. The [OceanStateEstimation.jl](https://github.com/JuliaOcean/OceanStateEstimation.jl) and [MeshArrays.jl](https://github.com/JuliaClimate/MeshArrays.jl) packages deal with gridded variables. 

\label{ocean-state-estimation}

- [ECCO\_standard\_plots.jl](https://JuliaOcean.github.io/OceanStateEstimation.jl/dev/examples/ECCO_standard_plots.html) ([notebook url](https://raw.githubusercontent.com/JuliaOcean/OceanStateEstimation.jl/master/examples/ECCO/ECCO_standard_plots.jl)) : visualize and compare NASA ocean state estimates ([ECCO reanalysis](https://ecco-group.org))
- [CBIOMES\_climatology\_plot.jll](https://JuliaOcean.github.io/OceanStateEstimation.jl/dev/examples/CBIOMES_climatology_plot.html) ([notebook url](https://raw.githubusercontent.com/JuliaOcean/OceanStateEstimation.jl/master/examples/CBIOMES/CBIOMES_climatology_plot.jl)) : climatology maps that describe marine ecosystems ([CBIOMES program](https://cbiomes.org))
- [SatelliteAltimetry.html](https://juliaocean.github.io/OceanRobots.jl/dev/examples/SatelliteAltimetry.html) ([notebook url](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/SatelliteAltimetry.jl)) : visualize regional sea level anomalies as mapped out by satellites

\lead{Local Data}

For both land and ocean areas, data collected locally in the field is often sparse. The examples below cover common file formats and various access protocols (http, ftp, opendap, thredds). 
[OceanRobots.jl](https://github.com/JuliaOcean/OceanRobots.jl) and [ArgoData.jl](https://github.com/JuliaOcean/ArgoData.jl) deal with such data collected in the Ocean. 

\label{ocean-robots}

- [OceanOPS.jl](https://JuliaOcean.github.io/OceanRobots.jl/dev/examples/OceanOPS.html) (➭ [notebook url](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/OceanOPS.jl)) : explore global ocean observing systems.
- [Buoy\_NWP\_NOAA.jl](https://JuliaOcean.github.io/OceanRobots.jl/dev/examples/Buoy_NWP_NOAA.html) (➭ [notebook url](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/Buoy_NWP_NOAA.jl)) : NOAA [station](https://www.ndbc.noaa.gov/) displays [NOAA station](https://www.ndbc.noaa.gov/) data.
- [Mooring\_WHOTS.jl](https://JuliaOcean.github.io/OceanRobots.jl/dev/examples/Mooring_WHOTS.html) (➭ [notebook url](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/Mooring_WHOTS.jl)) displays [WHOTS mooring](http://www.soest.hawaii.edu/whots/wh_data.html) data.
- [Drifter\_GDP.jl](https://JuliaOcean.github.io/OceanRobots.jl/dev/examples/Drifter_GDP.html) (➭ [notebook url](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/Drifter_GDP.jl)) displays a [drifter](https://www.aoml.noaa.gov/phod/gdp/hourly_data.php) time series.
- [Float\_Argo.jl](https://JuliaOcean.github.io/OceanRobots.jl/dev/examples/Float_Argo.html) (➭ [notebook url](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/Float_Argo.jl)) shows data from an [Argo](https://argo.ucsd.edu) profiling float.
- [Glider\_Spray.jl](https://JuliaOcean.github.io/OceanRobots.jl/dev/examples/Glider_Spray.html) (➭ [notebook url](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/Glider_Spray.jl)) : underwater [glider](http://spraydata.ucsd.edu/projects/) data.


\end{section}

\begin{section}{title="Numerical Models",name="Models"}

\label{climate-models}

\lead{Running Models}

[ClimateModels.jl](https://gaelforget.github.io/ClimateModels.jl/dev/) provides a uniform interface to climate models of varying complexity and completeness (up to whole Earth System models). The examples also illustrate cloud computing workflows that `replay` model output accessed from the web. Common file formats are supported. Version control, using _git_, is included to allow for workflow documentation and reproducibility.

- [Random walk model (0D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/RandomWalker.html) ➭ [notebook url](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/RandomWalker.jl) : two-dimensional random walk
- [ShallowWaters.jl model (2D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/ShallowWaters.html) ➭ [notebook url](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/ShallowWaters.jl) : shallow water equations
- [Oceananigans.jl model (3D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Oceananigans.html) ➭ [notebook url](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/Oceananigans.jl) : non-hydrostatic model
- [Hector climate model (global)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Hector.html) ➭ [notebook url](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/Hector.jl) : simple global climate carbon-cycle model 
- [FaIR	 climate model (global)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/FaIR.html) ➭ [notebook url](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/FaIR.jl) : simple global climate carbon-cycle model
- [SPEEDY atmosphere model (3D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Speedy.html) ➭ [notebook url](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/Speedy.jl) : fast, simplified, atmospheric model
- [MITgcm general circulation model (3D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/MITgcm.html) ➭ [notebook url](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/MITgcm.jl) : general circulation model

\lead{Local Models}

\label{individual-displacements}

[IndividualDisplacements.jl](https://juliaclimate.github.io/IndividualDisplacements.jl/dev/) supports the modeling of geophysical fluids at [moving point locations](https://en.wikipedia.org/wiki/Lagrangian_and_Eulerian_specification_of_the_flow_field). It computes single point displacements within a flow field, and follow individual fluid parcels as they move over time. 	

[IndividualDisplacements.jl](https://juliaclimate.github.io/IndividualDisplacements.jl/dev/) is geared towards the analysis of Climate, Ocean, etc model output over a gridded domain. It can simulate material transports within the Earth System (e.g., for plastics or planktons in the Ocean; dusts or chemicals in the Atmosphere). 

- [Simple Two-Dimensional Flow](https://juliaclimate.github.io/IndividualDisplacements.jl/dev/examples/random_flow_field.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/IndividualDisplacements.jl/master/examples/basics/random_flow_field.jl)) : simulate particle trajectories in 2D
- [Simple Three-Dimensional Flow](https://juliaclimate.github.io/IndividualDisplacements.jl/dev/examples/solid_body_rotation.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/IndividualDisplacements.jl/master/examples/basics/solid_body_rotation.jl)) : rotate, converge, and sink in 3D
- [Global Ocean Circulation (2D)](https://juliaclimate.github.io/IndividualDisplacements.jl/dev/examples/global_ocean_circulation.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/IndividualDisplacements.jl/master/examples/worldwide/global_ocean_circulation.jl)) : monthly flow climatology in 2D
- [Global Ocean Circulation (3D)](https://juliaclimate.github.io/IndividualDisplacements.jl/dev/examples/three_dimensional_ocean.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/IndividualDisplacements.jl/master/examples/worldwide/three_dimensional_ocean.jl)) : mean flow climatology in 3D

\lead{General Circulation Models}

\label{mitgcm-tools}

[MITgcmTools.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/) is a set of tools for running [MITgcm](https://mitgcm.readthedocs.io/en/latest/?badge=latest), analyzing its output, and so on. The `examples` folder provides a series of [Pluto.jl](https://github.com/fonsp/Pluto.jl) notebooks, which can be found in the package documentation. The examples run `MITgcm` interactively via the `ClimateModels.jl` interface, rely on `MeshArrays.jl` for visualizing results, use `IndividualDisplacements.jl` to derive material pathways, etc.

- [MITgcm_configurations.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/MITgcm_configurations.html) ([notebook url](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/MITgcm_configurations.jl)); explore MITgcm configurations and their parameters.
- [MITgcm\_scan\_output.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/MITgcm_scan_output.html) ([notebook url](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/MITgcm_scan_output.jl)) : scan run directory, standard output, read grid files, and visualize. 
- [MITgcm_run.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/MITgcm_run.html) ([notebook url](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/MITgcm_run.jl)) : a detailed look into compiling and running the model.
- [MITgcm_worklow.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/MITgcm_worklow.html) ([notebook url](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/MITgcm_worklow.jl)): build, setup, run, and plot for a chosen standard MITgcm configuration.
- [HS94_animation.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/HS94_animation.html) ([notebook url](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/HS94_animation.jl)) : run simple Atmosphere configuration, read output, interpolate, and plot maps.
- [HS94_particles.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/HS94_particles.html) ([notebook url](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/HS94_particles.jl)) : compute particle trajectories from model output generated in `HS94_animation.jl`.
- [HS94_Makie.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/HS94_Makie.html) ([notebook url](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/HS94_Makie.jl)) : using `Makie.jl` instead of `Plots.jl`

\end{section}

\begin{section}{title="Model Grids and Geography",name="Grids"}

\lead{MeshArrays.jl}

\label{mesh-arrays}

[MeshArrays.jl](https://juliaclimate.github.io/MeshArrays.jl/dev) defines an array type that can contain / organize / distribute collections of inter-connected arrays as generally done in climate models. These data structures can be used to simulate variables of the climate system such as [particles](https://doi.org/10.21105/joss.02813) and [transports](https://doi.org/10.1038/s41561-019-0333-7).

- [Geography](https://juliaclimate.github.io/MeshArrays.jl/dev/tutorials/geography.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/MeshArrays.jl/master/examples/geography.jl)) tutorial : deals with interpolation, projection, and visualization of gridded fields in geographic coordinates.
- [Vector Fields](https://juliaclimate.github.io/MeshArrays.jl/dev/tutorials/vectors.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/MeshArrays.jl/master/examples/vectors.jl)) tutorial : covers the computation of global transports, streamfunctions, potentials, gradients, curls, and more.
- [Basics](https://juliaclimate.github.io/MeshArrays.jl/dev/tutorials/basics.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/MeshArrays.jl/master/examples/basics.jl)) tutorial : illustrates how the MeshArrays.jl data structures let us write generic code readily applicable to whole families of grids.

\end{section}

\begin{section}{title="Files and Formats",name="Files"}

\label{files}

\lead{NetCDF}

The examples below use [NCDatasets.jl](https://alexander-barth.github.io/NCDatasets.jl/latest/). Alternatively, [NetCDF.jl](https://juliageo.github.io/NetCDF.jl/dev) provides a more direct interface for writing and reading netcdf files. 

- [NetCDF\_basics.jl](NetCDF_basics.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/Notebooks/master/tutorials/NetCDF_basics.jl)) is a brief tutorial that opens a netCDF file using [NCDatasets.jl](https://alexander-barth.github.io/NCDatasets.jl/latest/) and plots a 2D slice as a heatmap using [Makie.jl](https://makie.juliaplots.org/stable/).
- [NetCDF\_packages.jl](NetCDF_packages.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/Notebooks/master/tutorials/NetCDF_packages.jl)) reviews packages for ingesting NetCDF into various data structures; including [ClimateBase.jl](https://juliaclimate.github.io/ClimateBase.jl/dev/) and [ClimateTools.jl](https://juliaclimate.github.io/ClimateTools.jl/dev/).
- [NetCDF\_advanced.jl](NetCDF_advanced.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/Notebooks/master/tutorials/NetCDF_advanced.jl)) uses a large file to look at performance.

In addition, [Zarr.jl](https://juliaio.github.io/Zarr.jl/latest/) supports reading and writing `Zarr` Datasets from Julia. [NCTiles.jl](https://gaelforget.github.io/NCTiles.jl/dev) converts binary data into meta-data-rich [NetCDF](https://en.wikipedia.org/wiki/NetCDF) files for (1) a simple rectangular grid; (2) a tiled domain distributed over multiple files.

Finally, packages like [YAXArrays.jl](https://github.com/JuliaDataCubes/YAXArrays.jl#readme) and [Rasters.jl](https://github.com/rafaqz/Rasters.jl#readme) also focus on data structures that support netcdf. 

- [YAXArrays\_demo.jl](YAXArrays_demo.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/Notebooks/master/tutorials/YAXArrays_demo.jl)) uses a data cube approach.
- [xarray\_climarray\_etc.jl](http://gaelforget.net/notebooks/xarray_climarray_etc.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/Notebooks/master/tutorials/xarray_climarray_etc.jl)) uses Python's xarray and related Julia packages.

\lead{Other Files}

Here we look at vector and raster data. These notebooks illustrate several packages from the [JuliaGeo](https://juliageo.org) organization.

- [GeoTIFF\_demo.jl](GeoTIFF_demo.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/Notebooks/master/tutorials/GeoTIFF_demo.jl)) reads and plots a GeoTIFF file content using [ArchGDAL.jl](https://github.com/yeesian/ArchGDAL.jl#readme).
- [GeoJSON\_demo.jl](GeoJSON_demo.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/Notebooks/master/tutorials/GeoJSON_demo.jl)) reads and plots a GeoJSON file content using [GeoJSON.jl](https://github.com/JuliaGeo/GeoJSON.jl#readme).
- [Shapefile\_demo.jl](Shapefile_demo.html) ([notebook url](https://raw.githubusercontent.com/JuliaClimate/Notebooks/master/tutorials/Shapefile_demo.jl)) reads and plots a Shapefile file content using [Shapefile.jl](https://github.com/JuliaGeo/Shapefile.jl#readme).

The [Grids and Geography](#mesh-arrays) section looks at gridded output from a climate model more closely. Finally, the [Data Sets](#datasets) section provides examples also for file formats like `CSV`, `JLD2`, and binary files.

\end{section}

\begin{section}{title="User Directions",name="Directions"}

\label{directions}

**Get in Touch**

Please use the [repository issue tracker](https://guides.github.com/features/issues/) ([this one](https://github.com/JuliaClimate/Notebooks/issues)) for feedback, bug reports, queries, new contribution ideas, etc.

~~~
<br/>
~~~

**Run Notebooks**

\label{howto}

The [Pluto](https://github.com/fonsp/Pluto.jl/wiki/🔎-Basic-Commands-in-Pluto) notebook server can be used directly from your familiar Julia environment. Alternatively, you should be able use the computer configuration that we provide on any platform (cloud, laptop, or cluster) as explained below.

To start an interactive version of a notebook, you then launch `Pluto` and proceed as follows : 

- copy `notebook url` from webpage
- paste `notebook url` into Pluto
- click `open` and wait for notebook to boot up
- interact with the reactive notebook
- shut down or restart notebooks as needed

~~~
<br/>
~~~

\lead{Video demonstration (3 min)}

@@im-50
[![Video Tutorial](https://user-images.githubusercontent.com/20276764/159295950-d37fd926-209f-4b66-b5bf-6d003da66007.png)](https://www.youtube.com/watch?v=mZevMagHatc&list=PLXO7Tdh24uhPFZ5bph6Y_Q3-CRSfk5cDU)
@@

\lead{Step by step summary}

\begin{center}

@@im-20
[![Step 1](https://user-images.githubusercontent.com/20276764/156822528-fece5ce5-ae94-4d93-a2fe-7ff007a0fb13.png)](https://user-images.githubusercontent.com/20276764/156822528-fece5ce5-ae94-4d93-a2fe-7ff007a0fb13.png) [![Step 2](https://user-images.githubusercontent.com/20276764/156822529-6a58db73-c25e-4ffc-b768-5d4e9ee5e342.png)](https://user-images.githubusercontent.com/20276764/156822529-6a58db73-c25e-4ffc-b768-5d4e9ee5e342.png) [![Step 3](https://user-images.githubusercontent.com/20276764/156822530-f4e28e5f-0622-4f28-9906-3291dce99662.png)](https://user-images.githubusercontent.com/20276764/156822530-f4e28e5f-0622-4f28-9906-3291dce99662.png) [![Step 4](https://user-images.githubusercontent.com/20276764/156822531-b3556afb-75f5-43cb-80b2-43e401966140.png)](https://user-images.githubusercontent.com/20276764/156822531-b3556afb-75f5-43cb-80b2-43e401966140.png)
@@

\end{center}

~~~
<br/>
~~~

\lead{Alternative Methods}

You can specify the notebook URL or file path directly via `Pluto.run`. 

```
using Pluto, Downloads
path="examples/IPCC.jl"
Pluto.run(notebook=path)
```

Additionally, the [ClimateModels.jl]() package provides methods to gather and open any of the notebooks found in this page.

```
using Pluto, ClimateModels

Pluto.run()
pluto_url="http://localhost:1234/"

nbs=notebooks.list()
notebooks.open(pluto_url,notebook_url=nbs.url[1])
```

~~~
<br/>
~~~

**Computer Configuration**

\label{cloud}

Anyone should be able to run the provided computer configuration on a commercial cloud, a laptop, or a cluster from the [Docker image](https://hub.docker.com/r/gaelforget/notebooks) using this command for example:

```
docker run -p 8888:8888 gaelforget/notebooks:latest
```

A bit more explanation is provided [here in text](https://github.com/AIRCentre/JuliaEO/blob/main/docs/README-Docker-Intro.md) and [here in video](https://youtu.be/daNrJhPPgWg).

~~~
<br/>
~~~

\lead{Free Binder Service}

We are very grateful to the [BinderHub Federation](https://mybinder.readthedocs.io/en/latest/about/federation.html) for deploying public BinderHubs to serve the community at no cost to the user. 

\alert{Binder no longer works for this repository, for unclear reasons, as of Jan 2023. Instead it is recommended that you use the provided Docker image directly.}

\begin{center}

@@im-20
[![Step 1](https://user-images.githubusercontent.com/20276764/156822594-9dcb6899-e3f5-45d3-a595-dc89d97aafa8.png)](https://user-images.githubusercontent.com/20276764/156822594-9dcb6899-e3f5-45d3-a595-dc89d97aafa8.png) [![Step 2](https://user-images.githubusercontent.com/20276764/156822596-b84d806f-f6cb-4d13-af81-2f8b52f42237.png)](https://user-images.githubusercontent.com/20276764/156822596-b84d806f-f6cb-4d13-af81-2f8b52f42237.png) [![Step 3](https://user-images.githubusercontent.com/20276764/156822597-2bf1c0f7-aafe-49bd-863a-ff5be7658ca3.png)](https://user-images.githubusercontent.com/20276764/156822597-2bf1c0f7-aafe-49bd-863a-ff5be7658ca3.png)
@@

\end{center}

\end{section}

\begin{section}{title="About",name="About"}

\label{about}

The [User Directions](#directions) section is for those interested in running notebooks themselves.

- [How-To](#howto)
- [Cloud Services](#cloud)

\lead{Workshops}

\label{workshop}

The JuliaCon 2021 Workshop on `Modeling Marine Ecosystems At Multiple Scales Using Julia` was based on notebooks listed below. Additional detail is available in [this repository](https://github.com/JuliaOcean/MarineEcosystemsJuliaCon2021.jl).

- [AIBECS](https://juliaocean.github.io/MarineEcosystemsJuliaCon2021.jl/dev/AIBECSExample.html) ([notebook url](https://raw.githubusercontent.com/JuliaOcean/MarineEcosystemsJuliaCon2021.jl/main/src/AIBECSExample.jl)) : global steady-state biogeochemistry and gridded transport models that run fast for long time scales (centuries or even millennia).
- [PlanktonIndividuals](https://juliaocean.github.io/MarineEcosystemsJuliaCon2021.jl/dev/PlanktonIndividualExample.html) ([notebook url](https://raw.githubusercontent.com/JuliaOcean/MarineEcosystemsJuliaCon2021.jl/main/src/PlanktonIndividualExample.jl))  local to global agent-based model, particularly suited to study microbial communities, plankton physiology, and nutrient cycles.
- [MITgcm global biogeo](https://juliaocean.github.io/MarineEcosystemsJuliaCon2021.jl/dev/MITgcm_tutorial_global_oce_biogeo.html) ([notebook url](https://raw.githubusercontent.com/JuliaOcean/MarineEcosystemsJuliaCon2021.jl/main/src/MITgcm_tutorial_global_oce_biogeo.jl)) : interface to full-featured, Fortran-based, general circulation model and its output (transports, chemistry, ecology, ocean, sea-ice, atmosphere, and more).
- [IndividualDisplacements](https://juliaocean.github.io/MarineEcosystemsJuliaCon2021.jl/dev/IndividualDisplacementsExample.html) ([notebook url](https://raw.githubusercontent.com/JuliaOcean/MarineEcosystemsJuliaCon2021.jl/main/src/IndividualDisplacementsExample.jl)) : local to global particle tracking, for simulating dispersion, connectivity, transports in the ocean or atmosphere, etc.

\lead{References}

The notebooks mostly come from the `examples` section of various Julia packages.

- Data Products / [ClimateModels.jl](#climate-models) examples
- Data Products / [OceanStateEstimation.jl](#ocean-state-estimation) examples
- Data Products / [OceanRobots.jl](#ocean-robots) examples
- Models / [ClimateModels.jl](#climate-models) examples
- Models / [MITgcmTools.jl](#mitgcm-tools) examples
- Arrays / [MeshArrays.jl](#mesh-arrays) examples
- Points / [IndividualDisplacements.jl](#individual-displacements) examples

\lead{Packages}

Examples that use gridded data sets include the `OceanStateEstimation.jl` notebooks. `OceanRobots.jl` in turn deals with sparse data collected in situ by diverse methods. The examples cover common file formats and protocols for accessing data. 

The `ClimateModels.jl` package provides an interface to models often used in climate science. The examples either run models and generate new output, or replay model output generated earlier (e.g. from CMIP6 or the 2021 IPCC report). Additional examples for the [MIT general circulation model](https://mitgcm.readthedocs.io/en/latest/) are provided in `MITgcmTools.jl`.

An important requirement in climate science is to derive transports using native model grid output to e.g. precisely close energy budgets. This is one of the applications of `MeshArrays.jl` -- the analysis of global transports derived from gridded model output. Topics covered via `MeshArrays.jl` also include interpolation and geography.

`IndividualDisplacements.jl` extends this approach by providing a [particle tracking](https://en.wikipedia.org/wiki/Lagrangian_and_Eulerian_specification_of_the_flow_field) framework that readily operates on climate model `C-grids` using `MeshArrays.jl`. 
Examples that let you access and explore ocean data products are provided in `OceanRobots.jl` and `OceanStateEstimation.jl`. 

\lead{Visualization}

The maps, histograms, and other graphs found in the notebooks are generally created with [Makie.jl](https://makie.juliaplots.org/stable/). 

Other popular plotting libraries include [Plots.jl](http://docs.juliaplots.org/latest/), [Gnuplot.jl](https://github.com/gcalderone/Gnuplot.jl), [PyPlot.jl](https://github.com/JuliaPy/PyPlot.jl), [PlotlyJS.jl](http://juliaplots.org/PlotlyJS.jl/stable/), [GR.jl](https://github.com/jheinen/GR.jl), and [UnicodePlots.jl](https://github.com/JuliaPlots/UnicodePlots.jl).

\label{sample-viz}

\begin{center}

@@im-20
[![IPCC report figure 1b](https://user-images.githubusercontent.com/20276764/143275888-ff02f149-225f-45ac-ae5e-1049e15ab215.png)](https://user-images.githubusercontent.com/20276764/143275888-ff02f149-225f-45ac-ae5e-1049e15ab215.png) [![IPCC report figure 2](https://user-images.githubusercontent.com/20276764/135203143-ae838319-1a63-4ffe-8f08-1055174b79aa.png)](https://user-images.githubusercontent.com/20276764/135203143-ae838319-1a63-4ffe-8f08-1055174b79aa.png) [![IPCC report figure 3](https://user-images.githubusercontent.com/20276764/135203198-a5e2dc49-baee-4d13-a113-5433c074bbff.png)](https://user-images.githubusercontent.com/20276764/135203198-a5e2dc49-baee-4d13-a113-5433c074bbff.png) [![IPCC report figure 5](https://user-images.githubusercontent.com/20276764/135203214-ce6caece-13d1-49f3-9a70-7fa63d810e9c.png)](https://user-images.githubusercontent.com/20276764/135203214-ce6caece-13d1-49f3-9a70-7fa63d810e9c.png)
@@

@@im-20
[![Meridional Overturning](https://github.com/JuliaClimate/Notebooks/raw/master/page/figures/MOC.png)](https://github.com/JuliaClimate/Notebooks/raw/master/page/figures/MOC.png) [![Particle Tracking](https://user-images.githubusercontent.com/20276764/119210600-0dc9ba00-ba7b-11eb-96c1-e0f5dc75c838.png)](https://user-images.githubusercontent.com/20276764/119210600-0dc9ba00-ba7b-11eb-96c1-e0f5dc75c838.png) [![Vector Potential](https://github.com/JuliaClimate/Notebooks/raw/master/page/figures/Streamfunction.png)](https://github.com/JuliaClimate/Notebooks/raw/master/page/figures/Streamfunction.png) [![Scalar Potential](https://github.com/JuliaClimate/Notebooks/raw/master/page/figures/ScalarPotential.png)](https://github.com/JuliaClimate/Notebooks/raw/master/page/figures/ScalarPotential.png)
@@

\end{center}

\end{section}
