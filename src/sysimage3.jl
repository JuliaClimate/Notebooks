using PackageCompiler
create_sysimage([:WGLMakie];
                sysimage_path="WGLMakie.so",
                cpu_target = PackageCompiler.default_app_cpu_target())

using IJulia
installkernel("WGLMakie", "--sysimage=/home/jovyan/WGLMakie.so")

