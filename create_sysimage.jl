using PackageCompiler
create_sysimage([:CFTime, :CSV, :ClimateModels, :ColorSchemes, :DataFrames, :FortranFiles, 
                 :IJulia, :IndividualDisplacements, :MITgcmTools, :MeshArrays, :NCTiles, 
                 :NetCDF, :OceanStateEstimation, :Plots, :Pluto, :PlutoUI, :Printf, 
                 :UnicodePlots, :WGLMakie];
                precompile_execution_file = "warmup.jl",
                replace_default = true,
                cpu_target = PackageCompiler.default_app_cpu_target())
