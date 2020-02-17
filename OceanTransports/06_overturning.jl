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
#     display_name: Julia 1.2.0
#     language: julia
#     name: julia-1.2
# ---

# # Meridional Overturning Circulation
#
# This notebook requires downloading `nctiles_climatology/` from e.g. [ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/nctiles_climatology/]() as follows
#
# ```
# run(`wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/nctiles_climatology`)
# run(`mv mit.ecco-group.org/ecco_for_las/version_4/release2/nctiles_climatology ../inputs/`)
# ```

using MeshArrays, Plots, Statistics, MITgcmTools

# Read variables to memory

# +
if !isdir("../inputs/GRID_LLC90")
    run(`git clone https://github.com/gaelforget/GRID_LLC90 ../inputs/GRID_LLC90`)
end

mypath="../inputs/GRID_LLC90/"
mygrid=GridSpec("LatLonCap",mypath)
GridVariables=GridLoad(mygrid)
LC=LatitudeCircles(-89.0:89.0,GridVariables)

pth="../inputs/nctiles_climatology/"
msg="Please download $pth from e.g. `ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/`"
!isdir("$pth"*"UVELMASS") ? error(msg) : nothing
!isdir("$pth"*"VVELMASS") ? error(msg) : nothing

fileName="$pth"*"UVELMASS/UVELMASS"
U=Main.read_nctiles(fileName,"UVELMASS",mygrid)
fileName="$pth"*"VVELMASS/VVELMASS"
V=Main.read_nctiles(fileName,"VVELMASS",mygrid)

show(U)
# -

# ### Convert velocity (m/s) to transport (m^3/s)

for i in eachindex(U)
    tmp1=U[i]; tmp1[(!isfinite).(tmp1)] .= 0.0
    tmp1=V[i]; tmp1[(!isfinite).(tmp1)] .= 0.0    
    U[i]=GridVariables["DRF"][i[2]]*U[i].*GridVariables["DYG"][i[1]]
    V[i]=GridVariables["DRF"][i[2]]*V[i].*GridVariables["DXG"][i[1]]
end

# ### Compute overturning streamfunction

# +
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

ov=reverse(cumsum(reverse(ov,dims=2),dims=2),dims=2);
# -

# ### Plot annual mean

# +
x=vec(-89.0:89.0)
y=reverse(vec(GridVariables["RF"][1:end-1]))

tmp=dropdims(mean(ov,dims=3),dims=3)
z=reverse(tmp,dims=2)
z[z.==0.0].=NaN

contourf(x,y,1e-6*transpose(z),clims=(-40,40),
    title="Overturning mean (Eulerian; in Sv)",titlefontsize=10)
#savefig("MOC_mean.png")
# -
# ### Plot seasonal standard deviation

# +
tmp=dropdims(std(ov,dims=3),dims=3)
z=reverse(tmp,dims=2)
z[z.==0.0].=NaN

contourf(x,y,1e-6*transpose(z),clims=(-40,40),
    title="Overturning standard deviation (Eulerian; in Sv)",titlefontsize=10)
#savefig("MOC_std.png")
# -

