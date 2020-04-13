# -*- coding: utf-8 -*-
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
# # Interpolate `MeshArray` To Arbitrary Location
#
# Each `MeshArray` contains elementary arrays that collectively form a global domain grid. Here we interpolate from the global grid to a set of arbitary locations. This is commonly done e.g. to compare climate models to sparse field observations.
#
# In brief, the program finds a grid point quadrilateral (4 grid points) that encloses each chosen location. Computation is chuncked in subdomains (tiles) t o allow for parallelism. It outputs interpolation coefficients -- reusing those is easy and fast.

# + {"slideshow": {"slide_type": "subslide"}, "cell_type": "markdown"}
# ## Initialize Framework
#
# 1. import `MeshArrays` and plotting tools
# 2. choose e.g. a standard `MITgcm` grid
# 3. download the grid if needed
#

# + {"cell_style": "center", "slideshow": {"slide_type": "-"}}
using MeshArrays, MITgcmTools, Plots

pth="../inputs/GRID_LLC90/"
γ=GridSpec("LatLonCap",pth)
Γ=GridLoad(γ)

http="https://github.com/gaelforget/GRID_LLC90"
!isdir(pth) ? run(`git clone $http $pth`) : nothing;

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ## Interpolation Code
#
# - get map of tile numbers (`MeshArray`)
# - find nearest neighbor (`MeshArray` & `set`)
# - exchange and start loop (`tile` & `subset`)
#     - local stereographic projection
#     - define array of quadrilaterals
#     - find enclosing quadrilaterals
#     - compute interpolation coefficients

# + {"slideshow": {"slide_type": "subslide"}, "cell_type": "markdown"}
# ### Define Subdomain Tiles

# + {"slideshow": {"slide_type": "-"}}
ni=30; nj=30;
τ=Tiles(γ,ni,nj)

tiles=MeshArray(γ,Int);
[tiles[τ[i]["face"]][τ[i]["i"],τ[i]["j"]].=i for i in 1:length(τ)];   

using Plots
include(joinpath(dirname(pathof(MeshArrays)),"../examples/Plots.jl"))
heatmap(tiles,title="Tile ID",clims=(0,length(τ)))

# + {"slideshow": {"slide_type": "subslide"}, "cell_type": "markdown"}
# ### find nearest neighbor

# + {"slideshow": {"slide_type": "-"}}
using NearestNeighbors

XC=collect(0.1:0.5:2.1); YC=collect(0.1:0.5:2.1);
#XC=0.1; YC=0.1;

XC_a=write(Γ["XC"])
YC_a=write(Γ["YC"])
tiles_a=write(tiles)
kk=findall(isfinite.(XC_a))

x=sin.(pi/2 .-YC_a[kk]*pi/180).*cos.(XC_a[kk]*pi/180);
y=sin.(pi/2 .-YC_a[kk]*pi/180).*sin.(XC_a[kk]*pi/180);
z=cos.(pi/2 .-YC_a[kk]*pi/180);

xx=sin.(pi/2 .-YC*pi/180).*cos.(XC*pi/180);
yy=sin.(pi/2 .-YC*pi/180).*sin.(XC*pi/180);
zz=cos.(pi/2 .-YC*pi/180);

kdtree = KDTree([x y z]')
idxs, dists = knn(kdtree, [xx yy zz]', 4, true)

ik=[idxs[i][1] for i in 1:length(XC)]
[XC_a[ik] YC_a[ik] tiles_a[ik]]

# + {"slideshow": {"slide_type": "subslide"}, "cell_type": "markdown"}
# ### Prepare Arrays For Interpolation

# + {"slideshow": {"slide_type": "-"}}
list_tile=[tiles_a[ik]];
ii=1; iiTile=Int(list_tile[ii][1])
#println(iiTile)
#iiTile=17

XC_tmp=Tiles(τ,exchange(Γ["XC"]))[iiTile]
YC_tmp=Tiles(τ,exchange(Γ["YC"]))[iiTile]

iiFace=τ[iiTile]["face"]
ii0=minimum(τ[iiTile]["i"])+Int(ni/2)
jj0=minimum(τ[iiTile]["j"])+Int(nj/2)
XC0=Γ["XG"].f[iiFace][ii0,jj0]
YC0=Γ["YG"].f[iiFace][ii0,jj0]

#to match gcmfaces test case (`interp=gcmfaces_interp_coeffs(0.1,0.1);`) set:
#  iiTile=17; XC0=6.5000; YC0=-0.1994
#or equivalently:
#  ii0=Int(floor((iiMin+iiMax)/2)); jj0=Int(floor((jjMin+jjMax)/2));
#  XC0=Γ["XC"].f[iiFace][ii0,jj0]; YC0=Γ["YC"].f[iiFace][ii0,jj0];


# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Example Setup (Grid Space)

# + {"slideshow": {"slide_type": "-"}}
scatter(XC_tmp,YC_tmp,marker=:+,c=:blue,leg=false,xlabel="longitude",ylabel="latitude")
scatter!([XC0],[YC0],c=:red)
scatter!([XC],[YC],c=:green)

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Local Stereographic Projection

# + {"slideshow": {"slide_type": "-"}}
(xx,yy)=StereographicProjection(XC0,YC0,XC_tmp,YC_tmp)
(prof_x,prof_y)=StereographicProjection(XC0,YC0,XC,YC)
~isa(prof_x,Array) ? prof_x=[prof_x] : nothing
~isa(prof_y,Array) ? prof_y=[prof_y] : nothing

scatter(xx,yy,marker=:+,c=:blue,leg=false,xlabel="x",ylabel="y")
scatter!([0.],[0.],c=:red); scatter!(prof_x,prof_y,c=:green)

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Define Quadrilaterals

# +
x_quad=Array{Float64,2}(undef,(ni+1)*(nj+1),4)
y_quad=Array{Float64,2}(undef,(ni+1)*(nj+1),4)
i_quad=Array{Int64,2}(undef,(ni+1)*(nj+1),4)
j_quad=Array{Int64,2}(undef,(ni+1)*(nj+1),4)

didj=[[0 0];[1 0];[1 1];[0 1]]
for pp=1:4
    di=didj[pp,1]
    dj=didj[pp,2]

    #note the shift in indices due to exchange above
    tmp=xx[1+di:ni+1+di,1+dj:nj+1+dj]
    x_quad[:,pp]=vec(tmp)
    tmp=yy[1+di:ni+1+di,1+dj:nj+1+dj]
    y_quad[:,pp]=vec(tmp)

    tmp=collect(0+di:ni+di)*ones(1,nj+1)
    i_quad[:,pp]=vec(tmp)
    tmp=ones(ni+1,1)*transpose(collect(0+dj:nj+dj));
    j_quad[:,pp]=vec(tmp)
end

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Identify Quadrilaterals

# + {"slideshow": {"slide_type": "-"}}
angsum=PolygonAngle(x_quad,y_quad,prof_x,prof_y)
ii=findall(angsum.>180.)
ii=[ii[j].I[1] for j in 1:length(ii)]

scatter(xx,yy,marker=:+,c=:blue,leg=false)
scatter!([0.],[0.],c=:red)
scatter!(x_quad[ii,:],y_quad[ii,:],c=:orange)
scatter!(prof_x,prof_y,c=:green)

# + {"slideshow": {"slide_type": "slide"}, "cell_style": "center", "cell_type": "markdown"}
# ### Interpolation Coefficients

# + {"slideshow": {"slide_type": "-"}, "cell_style": "split"}
px=x_quad[ii[1],:]'
py=y_quad[ii[1],:]'
ox=[prof_x[1]]
oy=[prof_y[1]]

ow=QuadCoeffs(px,py,ox,oy)

Dict("face" => iiFace, "tile" => iiTile, "i" => i_quad[ii,:]', "j" => j_quad[ii,:]', "w" => dropdims(ow,dims=2))
# + {"cell_style": "split"}
px=x_quad[ii,:]
py=y_quad[ii,:]
ox=prof_x
oy=prof_y

ow=QuadCoeffs(px,py,ox,oy)

Dict("face" => iiFace, "tile" => iiTile, "i" => i_quad[ii,:], "j" => j_quad[ii,:], "w" => dropdims(ow,dims=2))
# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Verify Results
#
# Interpolate longitude and latitude from coefficients and compare with initial `XC,YC`.
#
# _Note that `XC_tmp,YC_tmp` each are `tile+halo`, which explains the `+1` index shift_

# +
XC_interp=similar(XC)
YC_interp=similar(YC)

for j=1:length(ox)
w=vec(ow[j,:,:])
x=[XC_tmp[i_quad[ii[j],i]+1,j_quad[ii[j],i]+1] for i=1:4]
y=[YC_tmp[i_quad[ii[j],i]+1,j_quad[ii[j],i]+1] for i=1:4]
#println([sum(w.*x) sum(w.*y)])
XC_interp[j]=sum(w.*x)
YC_interp[j]=sum(w.*y)
end

scatter(XC_tmp,YC_tmp,marker=:+,c=:blue,leg=false,xlabel="longitude",ylabel="latitude")
scatter!([XC0],[YC0],c=:red)
scatter!(XC_interp,YC_interp,c=:yellow,marker=:square)
scatter!(XC,YC,c=:red,marker=:star4)
# -


