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
lon=collect(0.1:0.5:2.1); lat=collect(0.1:0.5:2.1);
(f,i,j,a)=knn(Γ["XC"],Γ["YC"],lon,lat)
[write(Γ["XC"])[a] write(Γ["YC"])[a] write(tiles)[a]]

# + {"slideshow": {"slide_type": "subslide"}, "cell_type": "markdown"}
# ### Prepare Arrays For Interpolation

# + {"slideshow": {"slide_type": "-"}}
list_tile=unique(write(tiles)[a])

ii=1;
iiTile=list_tile[ii]

XCt=Tiles(τ,exchange(Γ["XC"]))[iiTile]
YCt=Tiles(τ,exchange(Γ["YC"]))[iiTile]

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
scatter(XCt,YCt,marker=:+,c=:blue,leg=false,xlabel="longitude",ylabel="latitude")
scatter!([XC0],[YC0],c=:red)
scatter!([lon],[lat],c=:green)

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Local Stereographic Projection

# + {"slideshow": {"slide_type": "-"}}
(x_grid,y_grid)=StereographicProjection(XC0,YC0,XCt,YCt)
(x_trgt,y_trgt)=StereographicProjection(XC0,YC0,lon,lat)
~isa(x_trgt,Array) ? x_trgt=[x_trgt] : nothing
~isa(y_trgt,Array) ? y_trgt=[y_trgt] : nothing

scatter(x_grid,y_grid,marker=:+,c=:blue,leg=false,xlabel="x",ylabel="y")
scatter!([0.],[0.],c=:red); scatter!(x_trgt,y_trgt,c=:green)

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
    tmp=x_grid[1+di:ni+1+di,1+dj:nj+1+dj]
    x_quad[:,pp]=vec(tmp)
    tmp=y_grid[1+di:ni+1+di,1+dj:nj+1+dj]
    y_quad[:,pp]=vec(tmp)

    tmp=collect(0+di:ni+di)*ones(1,nj+1)
    i_quad[:,pp]=vec(tmp)
    tmp=ones(ni+1,1)*transpose(collect(0+dj:nj+dj));
    j_quad[:,pp]=vec(tmp)
end

# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Identify Quadrilaterals

# + {"slideshow": {"slide_type": "-"}}
angsum=PolygonAngle(x_quad,y_quad,x_trgt,y_trgt)
ii=findall(angsum.>180.)
ii=[ii[j].I[1] for j in 1:length(ii)]

scatter(x_grid,y_grid,marker=:+,c=:blue,leg=false)
scatter!([0.],[0.],c=:red)
scatter!(x_quad[ii,:],y_quad[ii,:],c=:orange)
scatter!(x_trgt,y_trgt,c=:green)

# + {"slideshow": {"slide_type": "slide"}, "cell_style": "center", "cell_type": "markdown"}
# ### Interpolation Coefficients

# + {"slideshow": {"slide_type": "-"}, "cell_style": "split"}
px=x_quad[ii[1],:]'
py=y_quad[ii[1],:]'
ox=[x_trgt[1]]
oy=[y_trgt[1]]

ow=QuadCoeffs(px,py,ox,oy)

Dict("face" => iiFace, "tile" => iiTile, "i" => i_quad[ii,:]', "j" => j_quad[ii,:]', "w" => dropdims(ow,dims=2))
# + {"cell_style": "split"}
px=x_quad[ii,:]
py=y_quad[ii,:]
ox=x_trgt
oy=y_trgt

ow=QuadCoeffs(px,py,ox,oy)

Dict("face" => iiFace, "tile" => iiTile, "i" => i_quad[ii,:], "j" => j_quad[ii,:], "w" => dropdims(ow,dims=2))
# + {"slideshow": {"slide_type": "slide"}, "cell_type": "markdown"}
# ### Verify Results
#
# Interpolate longitude and latitude from coefficients and compare with initial `XC,YC`.
#
# _Note that `XCt,YCt` each are `tile+halo`, which explains the `+1` index shift_

# +
lon_i=similar(lon)
lat_i=similar(lat)
for j=1:length(ox)
    w=vec(ow[j,:,:])
    x=[XCt[i_quad[ii[j],i]+1,j_quad[ii[j],i]+1] for i=1:4]
    y=[YCt[i_quad[ii[j],i]+1,j_quad[ii[j],i]+1] for i=1:4]
    #println([sum(w.*x) sum(w.*y)])
    lon_i[j]=sum(w.*x)
    lat_i[j]=sum(w.*y)
end

scatter(XCt,YCt,marker=:+,c=:blue,leg=false,xlabel="longitude",ylabel="latitude")
scatter!([XC0],[YC0],c=:red)
scatter!(lon_i,lat_i,c=:yellow,marker=:square)
scatter!(lon,lat,c=:red,marker=:star4)
# -


