using PackageCompiler
create_sysimage([:IJulia, :Pluto, :PlutoUI, :PyCall, :Conda, 
                :MeshArrays, :ClimateModels, :MITgcmTools,
                :IndividualDisplacements, :Dataverse, 
                :OceanRobots, :OceanStateEstimation,
                :CairoMakie];
                precompile_execution_file = "sysimage/warmup.jl",
                sysimage_path="ExampleSysimage.so",
                cpu_target = PackageCompiler.default_app_cpu_target())
