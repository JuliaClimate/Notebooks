using PackageCompiler
create_sysimage([:CairoMakie];
                sysimage_path="CairoMakie.so",
                cpu_target = PackageCompiler.default_app_cpu_target())

using IJulia
installkernel("CairoMakie", "--sysimage=/home/jovyan/CairoMakie.so")

