using PackageCompiler
create_sysimage([:CairoMakie,:WGLMakie,:Plots,:CSV,:DataFrames];
                sysimage_path="/usr/local/etc/gf/viz.so",
                cpu_target = PackageCompiler.default_app_cpu_target())

using IJulia
installkernel("viz", "--sysimage=/usr/local/etc/gf/viz.so")

