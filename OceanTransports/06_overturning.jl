# ---
# jupyter:
#   jupytext:
#     formats: ipynb,jl:light
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.4'
#       jupytext_version: 1.2.4
#   kernelspec:
#     display_name: Julia 1.3.1
#     language: julia
#     name: julia-1.3
# ---

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# # Meridional Overturning Circulation
#
# Global Ocean transport depictions often involve concepts like the [AMOC](https://en.wikipedia.org/wiki/Atlantic_meridional_overturning_circulation), [Thermohaline Circulation](https://en.wikipedia.org/wiki/Thermohaline_circulation), or [conveyor Belt](http://oceanmotion.org/html/background/ocean-conveyor-belt.html). To apply these concepts to gridded ocean and climate models, one can compute an `overturning streamfunction` as shown below. For more detail, please refer to [Forget et al, 2015](https://doi.org/10.5194/gmd-8-3071-2015) and the other [GlobalOceanNotebooks](https://github.com/JuliaClimate/GlobalOceanNotebooks).

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Read grid & velocities from file
#
# 1. pre-requisites
# 2. read variables
# 3. conversion to transports

# + {"slideshow": {"slide_type": "subslide"}}
using MeshArrays, Plots, Statistics, MITgcmTools

if !isdir("../inputs/GRID_LLC90")
    run(`git clone https://github.com/gaelforget/GRID_LLC90 ../inputs/GRID_LLC90`)
end

# +
using CSV, DataFrames

function get_from_dataverse(nam::String,pth::String)
    tmp = CSV.File("nctiles_climatology.csv") |> DataFrame!
    ii = findall([occursin("$nam", tmp[i,:name]) for i=1:size(tmp,1)])
    !isdir("$pth"*"$nam") ? mkdir("$pth"*"$nam") : nothing
    for i in ii
        ID=tmp[i,:ID]
        nam1=tmp[i,:name]
        nam2=joinpath("$pth"*"$nam/",nam1)
        run(`wget --content-disposition https://dataverse.harvard.edu/api/access/datafile/$ID`);
        run(`mv $nam1 $nam2`);
    end
end

# +
pth="../inputs/nctiles_climatology/"

!isdir("$pth") ? mkdir("$pth") : nothing 
!isdir("$pth"*"UVELMASS") ? get_from_dataverse("UVELMASS",pth) : nothing
!isdir("$pth"*"VVELMASS") ? get_from_dataverse("VVELMASS",pth) : nothing

# + {"slideshow": {"slide_type": "fragment"}}
mypath="../inputs/GRID_LLC90/"
mygrid=GridSpec("LatLonCap",mypath)
GridVariables=GridLoad(mygrid)
LC=LatitudeCircles(-89.0:89.0,GridVariables)

fileName="$pth"*"UVELMASS/UVELMASS"
U=Main.read_nctiles(fileName,"UVELMASS",mygrid)
fileName="$pth"*"VVELMASS/VVELMASS"
V=Main.read_nctiles(fileName,"VVELMASS",mygrid);

# + {"slideshow": {"slide_type": "fragment"}}
#Convert Velocity (m/s) to transport (m^3/s)
for i in eachindex(U)
    tmp1=U[i]; tmp1[(!isfinite).(tmp1)] .= 0.0
    tmp1=V[i]; tmp1[(!isfinite).(tmp1)] .= 0.0    
    U[i]=GridVariables["DRF"][i[2]]*U[i].*GridVariables["DYG"][i[1]]
    V[i]=GridVariables["DRF"][i[2]]*V[i].*GridVariables["DXG"][i[1]]
end

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Compute Overturning Streamfunction
#
# 1. define `grid edge paths` that track latitude circles
# 2. integrate along these `grid edge paths` and from the bottom

# + {"slideshow": {"slide_type": "-"}}
#integrate across latitude circles
s=size(U); nz=s[2]; nl=length(LC)
nt=1; ov=Array{eltype(U),2}(undef,nl,nz)
length(s)>2 ? nt=s[3] : nothing
length(s)>2 ? ov=Array{eltype(U),3}(undef,nl,nz,nt) : nothing
for t=1:nt; for z=1:nz; 
        length(s)>2 ? tmpU=U[:,z,t] : tmpU=U[:,z]
        length(s)>2 ? tmpV=V[:,z,t] : tmpV=V[:,z]
        UV=Dict("U"=>tmpU,"V"=>tmpV,"dimensions"=>["x","y"])
        for l=1:nl
            ov[l,z,t]=ThroughFlow(UV,LC[l],GridVariables)
        end
end; end;

#integrate from bottom
ov=reverse(cumsum(reverse(ov,dims=2),dims=2),dims=2);

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Plot Annual Mean And Variability
# -

x=vec(-89.0:89.0); y=reverse(vec(GridVariables["RF"][1:end-1])); #coordinate variables

# + {"slideshow": {"slide_type": "fragment"}, "cell_style": "split"}
tmp=dropdims(mean(ov,dims=3),dims=3)
z=reverse(tmp,dims=2)
z[z.==0.0].=NaN

contourf(x,y,1e-6*transpose(z),clims=(-40,40),
    title="Overturning mean (Eulerian; in Sv)",titlefontsize=10)
#savefig("MOC_mean.png")
# + {"slideshow": {"slide_type": "fragment"}, "cell_style": "split"}
tmp=dropdims(std(ov,dims=3),dims=3)
z=reverse(tmp,dims=2)
z[z.==0.0].=NaN

contourf(x,y,1e-6*transpose(z),clims=(-40,40),
    title="Overturning standard deviation (Eulerian; in Sv)",titlefontsize=10)
#savefig("MOC_std.png")
# -

