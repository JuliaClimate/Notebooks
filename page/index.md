
\begin{section}{title="Overview",name="Overview"}

\label{introduction}

[![Binder](https://mybinder.org/badge_logo.svg)](https://gesis.mybinder.org/v2/gh/JuliaClimate/GlobalOceanNotebooks/HEAD?urlpath=lab)
[![DOI](https://zenodo.org/badge/147266407.svg)](https://zenodo.org/badge/latestdoi/147266407)

Here we present series of [Julia](https://julialang.org) notebooks (see [Pluto.jl](https://plutojl.org)) that demo [JuliaClimate](https://github.com/JuliaClimate/) packages working in concert together and within the broader package ecosystem. Users should be able to replay these notebooks either on a local computer or in the cloud (see [these docs](https://github.com/fonsp/Pluto.jl/wiki) and the bottom of this page for directions).

\end{section}

\begin{section}{title="Contents",name="Contents"}

\label{contents}

- [Visual Examples](#sample-viz)
- [ClimateModels.jl](#climate-models)
- [MITgcmTools.jl](#mitgcm-tools)
- [MeshArrays.jl](#mesh-arrays)
- [IndividualDisplacements.jl](#individual-displacements)
- [OceanRobots.jl](#ocean-robots)
- [OceanStateEstimation.jl](#ocean-state-estimation)
- [Miscellaneous](#misc)

The `ClimateModels.jl` package provides an interface to models often used in climate science. Included notebooks provide examples that either run models and generate new output, or replay model output generated earlier (e.g. from CMIP6 or the 2021 IPCC report). Additional examples for the [MIT general circulation model](https://mitgcm.readthedocs.io/en/latest/) are provided in `MITgcmTools.jl`.

An important requirement in climate science is to derive transports using native model grid output to e.g. precisely close energy budgets. This is one of the applications of `MeshArrays.jl` -- the analysis of global transports derived from gridded model output. Topics covered via `MeshArrays.jl` also include interpolation and geography.

`IndividualDisplacements.jl` extends this approach by providing a [particle tracking](https://en.wikipedia.org/wiki/Lagrangian_and_Eulerian_specification_of_the_flow_field) framework that readily operates on climate model `C-grids` using `MeshArrays.jl`. 
Examples that let you access and explore ocean data products are provided in `OceanRobots.jl` and `OceanStateEstimation.jl`. The `miscellaneous` section touches on topics such as files (incl. NetCDF and Zarr), visualization, cloud services, and user directions.

\end{section}

\begin{section}{title="Visual Examples",name="Visuals"}

\label{sample-viz}

The plots below are examples generated using the Julia packages listed in the [introduction](#introduction) and notebooks indicated below.

\begin{center}

\figure{path="https://github.com/JuliaClimate/GlobalOceanNotebooks/raw/master/page/figures/MOC.png", width="150", style="border-radius:5px;", caption="Meridional Overturning Streamfunction"} \figure{path="https://user-images.githubusercontent.com/20276764/119210600-0dc9ba00-ba7b-11eb-96c1-e0f5dc75c838.png", width="150", style="border-radius:5px;", caption="Particle Tracking"} 
\figure{path="https://github.com/JuliaClimate/GlobalOceanNotebooks/raw/master/page/figures/Streamfunction.png", width="150", style="border-radius:5px;", caption="Vector Potential"} \figure{path="https://github.com/JuliaClimate/GlobalOceanNotebooks/raw/master/page/figures/ScalarPotential.png", width="150", style="border-radius:5px;", caption="Scalar Potential"} 

\figure{path="https://user-images.githubusercontent.com/20276764/143275888-ff02f149-225f-45ac-ae5e-1049e15ab215.png", width="150", style="border-radius:5px;", caption="IPCC report fig 1b"} \figure{path="https://user-images.githubusercontent.com/20276764/135203143-ae838319-1a63-4ffe-8f08-1055174b79aa.png", width="150", style="border-radius:5px;", caption="IPCC report fig 2"}
\figure{path="https://user-images.githubusercontent.com/20276764/135203198-a5e2dc49-baee-4d13-a113-5433c074bbff.png", width="140", style="border-radius:5px;", caption="IPCC report fig 3"} \figure{path="https://user-images.githubusercontent.com/20276764/135203214-ce6caece-13d1-49f3-9a70-7fa63d810e9c.png", width="160", style="border-radius:5px;", caption="IPCC report fig 5"}

\end{center}

\end{section}

\begin{section}{title="ClimateModels.jl",name="Models"}

\label{climate-models}

[ClimateModels.jl](https://gaelforget.github.io/ClimateModels.jl/dev/) provides a uniform interface to climate models of varying complexity and completeness. Models that range from low dimensional to whole Earth System models can be run and/or analyzed via this framework. It also supports e.g. cloud computing workflows that start from previous model output available over the internet. Common file formats are supported. Version control, using _git_, is included to allow for workflow documentation and reproducibility.

`Running Models`

- [Random walk model (0D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/RandomWalker.html) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/RandomWalker.jl)
- [ShallowWaters.jl model (2D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/ShallowWaters.html) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/ShallowWaters.jl)
- [Oceananigans.jl model (3D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Oceananigans.html) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/Oceananigans.jl)
- [Hector climate model (global)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Hector.html) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/Hector.jl)
- [FaIR	 climate model (global)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/FaIR.html) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/FaIR.jl)
- [SPEEDY atmosphere model (3D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Speedy.html) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/Speedy.jl)
- [MITgcm general circulation model (3D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/MITgcm.html) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/MITgcm.jl)

`Replaying Outputs`

- [CMIP6 model output](https://gaelforget.github.io/ClimateModels.jl/dev/examples/CMIP6.html) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/CMIP6.jl)
- [2021 climate report](https://gaelforget.github.io/ClimateModels.jl/dev/examples/IPCC.html) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/IPCC.jl)

`MIT general circulation model`

\label{mitgcm-tools}

[MITgcmTools.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/) is a set of tools for running [MITgcm](https://mitgcm.readthedocs.io/en/latest/?badge=latest), analyzing its output, and/or modifying its inputs. The package documentation provides a series of [Pluto.jl](https://github.com/fonsp/Pluto.jl) notebooks, which e.g. run `MITgcm` interactively via the `ClimateModels.jl` interface, rely on `MeshArrays.jl` for visualizing results, or use `IndividualDisplacements.jl` to derive material pathways.

- [MITgcm_configurations.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/MITgcm_configurations.html) ([code link](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/MITgcm_configurations.jl)); explore MITgcm configurations and their parameters.
- [MITgcm\_scan\_output.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/MITgcm_scan_output.html) ([code link](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/MITgcm_scan_output.jl)) : scan run directory, standard output, read grid files, and visualize. 
- [MITgcm_run.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/MITgcm_run.html) ([code link](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/MITgcm_run.jl)) : a detailed look into compiling and running the model.
- [MITgcm_worklow.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/MITgcm_worklow.html) ([code link](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/MITgcm_worklow.jl)): build, setup, run, and plot for a chosen standard MITgcm configuration.
- [HS94_animation.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/HS94_animation.html) ([code link](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/HS94_animation.jl)) : run simple Atmosphere configuration, read output, interpolate, and plot maps.
- [HS94_particles.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/HS94_particles.html) ([code link](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/HS94_particles.jl)) : compute particle trajectories from model output generated in `HS94_animation.jl`.
- [HS94_Makie.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/HS94_Makie.html) ([code link](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/HS94_Makie.jl)) : using `Makie.jl` instead of `Plots.jl`

\end{section}

\begin{section}{title="MeshArrays.jl",name="Arrays"}

\label{mesh-arrays}

[MeshArrays.jl](https://juliaclimate.github.io/MeshArrays.jl/dev) defines an array type that can contain / organize / distribute collections of inter-connected arrays as generally done in climate models. These data structures can be used to simulate variables of the climate system such as [particles](https://doi.org/10.21105/joss.02813) and [transports](https://doi.org/10.1038/s41561-019-0333-7).

- [Geography](https://juliaclimate.github.io/MeshArrays.jl/dev/tutorials/geography.html) ([code link](https://raw.githubusercontent.com/JuliaClimate/MeshArrays.jl/master/examples/geography.jl)) tutorial : deals with interpolation, projection, and visualization of gridded fields in geographic coordinates.
- [Vector Fields](https://juliaclimate.github.io/MeshArrays.jl/dev/tutorials/vectors.html) ([code link](https://raw.githubusercontent.com/JuliaClimate/MeshArrays.jl/master/examples/vectors.jl)) tutorial : covers the computation of global transports, streamfunctions, potentials, gradients, curls, and more.
- [Basics](https://juliaclimate.github.io/MeshArrays.jl/dev/tutorials/basics.html) ([code link](https://raw.githubusercontent.com/JuliaClimate/MeshArrays.jl/master/examples/basics.jl)) tutorial : illustrates how the MeshArrays.jl data structures let us write generic code readily applicable to whole families of grids.

\end{section}

\begin{section}{title="IndividualDisplacements.jl",name="Particles"}

\label{individual-displacements}

[IndividualDisplacements.jl](https://juliaclimate.github.io/IndividualDisplacements.jl/dev/) computes point displacements over a gridded domain. It is geared towards the analysis of Climate, Ocean, etc models (`Arakawa C-grids` are natively supported) and the simulation of material transports within the Earth System (e.g. plastics or planktons in the Ocean; dusts or chemicals in the Atmosphere). 

- [Simple Two-Dimensional Flow](https://juliaclimate.github.io/IndividualDisplacements.jl/dev/examples/random_flow_field.html) ([code link](https://raw.githubusercontent.com/JuliaClimate/IndividualDisplacements.jl/master/examples/basics/random_flow_field.jl))
- [Simple Three-Dimensional Flow](https://juliaclimate.github.io/IndividualDisplacements.jl/dev/examples/solid_body_rotation.html) ([code link](https://raw.githubusercontent.com/JuliaClimate/IndividualDisplacements.jl/master/examples/basics/solid_body_rotation.jl))
- [Global Ocean Circulation (2D)](https://juliaclimate.github.io/IndividualDisplacements.jl/dev/examples/global_ocean_circulation.html) ([code link](https://raw.githubusercontent.com/JuliaClimate/IndividualDisplacements.jl/master/examples/worldwide/global_ocean_circulation.jl))
- [Global Ocean Circulation (3D)](https://juliaclimate.github.io/IndividualDisplacements.jl/dev/examples/three_dimensional_ocean.html) ([code link](https://raw.githubusercontent.com/JuliaClimate/IndividualDisplacements.jl/master/examples/worldwide/three_dimensional_ocean.jl))

\end{section}

\begin{section}{title="Data Products",name="Data"}

[OceanRobots.jl](https://github.com/gaelforget/OceanRobots.jl) : Simulation, processing, and analysis of data generated by scientific robots in the Ocean. These include profiling floats (Argo), drifters (GDP), and moorings for examples.

\label{ocean-robots}

- [example\_NWP\_NOAA.jl](examples/example_NWP_NOAA.html) (➭ [code link](https://raw.githubusercontent.com/gaelforget/OceanRobots.jl/master/examples/example_NWP_NOAA.jl)) displays [NOAA station](https://www.ndbc.noaa.gov/) data
- [example\_WHOTS.jl](examples/example_WHOTS.html) (➭ [code link](https://raw.githubusercontent.com/gaelforget/OceanRobots.jl/master/examples/example_WHOTS.jl)) displays [WHOTS mooring](http://www.soest.hawaii.edu/whots/wh_data.html) data
- [example\_GDP.jl](examples/example_GDP.html) (➭ [code link](https://raw.githubusercontent.com/gaelforget/OceanRobots.jl/master/examples/example_GDP.jl)) displays a [drifter](https://www.aoml.noaa.gov/phod/gdp/hourly_data.php) time series
- [example\_Argo.jl](examples/example_Argo.html) (➭ [code link](https://raw.githubusercontent.com/gaelforget/OceanRobots.jl/master/examples/example_Argo.jl)) shows data from an [Argo](https://argo.ucsd.edu) profiling float


[OceanStateEstimation.jl](https://github.com/gaelforget/OceanStateEstimation.jl) : package currently focused on serving and deriving climatologies from ocean state estimates.

\label{ocean-state-estimation}

- [ECCO\_standard\_plots.jl](https://gaelforget.github.io/OceanStateEstimation.jl/dev/examples/ECCO_standard_plots.html) ([code link](https://raw.githubusercontent.com/gaelforget/OceanStateEstimation.jl/master/examples/ECCO/ECCO_standard_plots.jl)) : visualize and compare NASA ocean state estimates ([ECCO reanalysis](https://ecco-group.org))
- [CBIOMES\_climatology\_plot.jll](https://gaelforget.github.io/OceanStateEstimation.jl/dev/examples/CBIOMES_climatology_plot.html) ([code link](https://raw.githubusercontent.com/gaelforget/OceanStateEstimation.jl/master/examples/CBIOMES/CBIOMES_climatology_plot.jl)) : climatology maps that describe marine ecosystems ([CBIOMES program](https://cbiomes.org))

\end{section}

\begin{section}{title="Marine Ecosystem Modeling Workshop",name="Workshops"}

\label{workshop}

Notebooks below were presented as part of the JuliaCon 2021 Workshop on `Modeling Marine Ecosystems At Multiple Scales Using Julia`. More detail is available in the [workshop repository](https://github.com/JuliaOcean/MarineEcosystemsJuliaCon2021.jl).

- [AIBECSExample](https://juliaocean.github.io/MarineEcosystemsJuliaCon2021.jl/dev/AIBECSExample.html) ([code link](https://github.com/JuliaOcean/MarineEcosystemsJuliaCon2021.jl/blob/main/AIBECSExample.jl)) : global steady-state biogeochemistry and gridded transport models that run fast for long time scales (centuries or even millennia).
- [PlanktonIndividualExample](https://juliaocean.github.io/MarineEcosystemsJuliaCon2021.jl/dev/PlanktonIndividualExample.html) ([code link](https://juliaocean.github.io/MarineEcosystemsJuliaCon2021.jl/dev/PlanktonIndividualExample.jl))  local to global agent-based model, particularly suited to study microbial communities, plankton physiology, and nutrient cycles.
- [MITgcm\_tutorial\_global\_oce\_biogeo](https://juliaocean.github.io/MarineEcosystemsJuliaCon2021.jl/dev/MITgcm_tutorial_global_oce_biogeo.html) ([code link](https://juliaocean.github.io/MarineEcosystemsJuliaCon2021.jl/dev/MITgcm_tutorial_global_oce_biogeo.jl)) : interface to full-featured, Fortran-based, general circulation model and its output (transports, chemistry, ecology, ocean, sea-ice, atmosphere, and more).
- [IndividualDisplacementsExample](https://juliaocean.github.io/MarineEcosystemsJuliaCon2021.jl/dev/IndividualDisplacementsExample.html) ([code link](https://juliaocean.github.io/MarineEcosystemsJuliaCon2021.jl/dev/IndividualDisplacementsExample.jl)) : local to global particle tracking, for simulating dispersion, connectivity, transports in the ocean or atmosphere, etc.

\end{section}

\begin{section}{title="Miscellaneous",name="More"}

\label{misc}

- To start an interactive version of a notebook, on your computer or in the cloud, open `Pluto.jl`, and paste the notebook `code link`. For cloud computing options, please scroll down to the [mybinder section](#mybinder-links).
- The above examples provide a suite of recipes to draw maps, histograms, time series, and more using [Makie.jl](https://makie.juliaplots.org/stable/) or [Plots.jl](http://docs.juliaplots.org/latest/). Other popular plotting libraries include [Gnuplot.jl](https://github.com/gcalderone/Gnuplot.jl), [PyPlot.jl](https://github.com/JuliaPy/PyPlot.jl), [PlotlyJS.jl](http://juliaplots.org/PlotlyJS.jl/stable/), [GR.jl](https://github.com/jheinen/GR.jl), and [UnicodePlots.jl](https://github.com/JuliaPlots/UnicodePlots.jl).
- [VizNc.jl](https://juliaclimate.github.io/GlobalOceanNotebooks/VizNc.html) ([code link](https://raw.githubusercontent.com/JuliaClimate/GlobalOceanNotebooks/master/tutorials/VizNc.jl)) is a brief tutorial that opens a netCDF file using [NCDatasets.jl](https://alexander-barth.github.io/NCDatasets.jl/latest/) and plots a 2D slice as a heatmap using [Makie.jl](https://makie.juliaplots.org/stable/).
- [NCTiles.jl](https://gaelforget.github.io/NCTiles.jl/dev) converts binary data into meta-data-rich [NetCDF](https://en.wikipedia.org/wiki/NetCDF) files for (1) a simple rectangular grid; (2) a tiled domain distributed over multiple files.
- Please use the [repository issue tracker](https://guides.github.com/features/issues/) ([this one](https://github.com/JuliaClimate/GlobalOceanNotebooks/issues)) for queries, bug reports, new contributions, etc.

\label{mybinder-links}

**Open Cloud Services**

We are very grateful to the [BinderHub Federation](https://mybinder.readthedocs.io/en/latest/about/federation.html) for deploying public BinderHubs to serve the community. Visiting [mybinder.org](https://mybinder.org) will randomly redirect you to one of the BinderHubs selected at random. The shorcuts below are configured for the `JuliaClimate` repository more specifically. They should be able to run the notebooks listed above with reduced latency. Memory limitations can be an issue though. 

\alert{For repeated use it is suggested that you run the notebooks on your local computer instead if possible. Not only will this probably be faster than using mybinder but it will also save mybinder some of the funds that allow them to provide these precious, shared, cloud services to the community free of charge.}

- [gesis.mybinder.org](https://gesis.mybinder.org/v2/gh/JuliaClimate/GlobalOceanNotebooks/HEAD?urlpath=lab)
- [gke.mybinder.org](https://gke.mybinder.org/v2/gh/JuliaClimate/GlobalOceanNotebooks/HEAD?urlpath=lab)
- [ovh.mybinder.org](https://ovh.mybinder.org/v2/gh/JuliaClimate/GlobalOceanNotebooks/HEAD?urlpath=lab)
- [turing.mybinder.org](https://turing.mybinder.org/v2/gh/JuliaClimate/GlobalOceanNotebooks/HEAD?urlpath=lab)

To run a notebook locally, i.e. on your computer rather than in the cloud, open `julia`, copy the `code link` for the chosen notebook, and execute the following commands. Or start [Pluto.jl](https://github.com/fonsp/Pluto.jl/wiki) from `julia` and paste the url afterwards.

```
using Pluto, Downloads
url="https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/IPCC.jl"
Pluto.run(notebook=Downloads.download(url))
```

\end{section}
