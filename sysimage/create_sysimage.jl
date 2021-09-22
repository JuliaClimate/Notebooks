using PackageCompiler
create_sysimage([:CSV, :ClimateModels, :DataFrames, 
                 :IJulia, :IndividualDisplacements, :MITgcmTools, 
                 :Plots, :Pluto, :PlutoUI, :UnicodePlots, :WGLMakie];
                precompile_execution_file = "warmup.jl",
                replace_default = true,
                cpu_target = PackageCompiler.default_app_cpu_target())
