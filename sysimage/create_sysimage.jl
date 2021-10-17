using PackageCompiler
create_sysimage([:CSV, :ClimateModels, :DataFrames, 
                 :IJulia, :IndividualDisplacements, :MITgcmTools, 
                 :Plots, :Pluto, :PlutoUI, :UnicodePlots, :CairoMakie];
                precompile_execution_file = "sysimage/warmup.jl",
                sysimage_path="ExampleSysimage.so",
                cpu_target = PackageCompiler.default_app_cpu_target())
