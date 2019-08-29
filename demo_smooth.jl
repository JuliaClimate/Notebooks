# ---
# jupyter:
#   jupytext:
#     formats: ipynb,jl:light
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.4'
#       jupytext_version: 1.2.1
#   kernelspec:
#     display_name: Julia 1.1.0
#     language: julia
#     name: julia-1.1
# ---

# ## `MeshArrays.jl` test suite uses a global smoother function

# Load the `MeshArrays.jl` and `Plots.jl` package modules

using MeshArrays, Plots

#for backward compatibility:
!isdefined(MeshArrays,:GridSpec) ? GridSpec=GCMGridSpec : nothing
!isdefined(MeshArrays,:GridLoad) ? GridLoad=GCMGridLoad : nothing
!isdefined(MeshArrays,:GridOfOnes) ? GridOfOnes=GCMGridOnes : nothing

# Define a grid with `6` faces of `16*16` points and distances, areas, etc. all set to `1.0`:

GridVariables=GridOfOnes("cs",6,16);

# Smooth a randomly initialized `Rini` at 3 grid point scales (`DXCsm,DYCsm`):

(Rini,Rend,DXCsm,DYCsm)=MeshArrays.demo2(GridVariables);

# Define `qwckplot` and use it to vizualize the resulting `Rend`:

# +
function qwckplot(fld::MeshArray,ttl::String)
    arr=MeshArrays.convert2array(fld)
    arr=permutedims(arr,[2 1])
    #This uses Plots.jl:
    p=heatmap(arr,title=ttl)
end

qwckplot(Rend,"Smoothed noise")
# -

# Note the increased smoothness and reduced magnitude as compared with `Rini`:

qwckplot(Rini,"Original noise")

# To finish, let's benchmark `smooth` as a function of smoothing scale parameters:

@time Rend=smooth(Rini,DXCsm,DYCsm,GridVariables);
@time Rend=smooth(Rini,2DXCsm,2DYCsm,GridVariables);


