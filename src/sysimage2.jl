using PackageCompiler
create_sysimage([:Plots];
                sysimage_path="Plots.so",
                cpu_target = PackageCompiler.default_app_cpu_target())

using IJulia
installkernel("Plots", "--sysimage=/home/jovyan/Plots.so")

