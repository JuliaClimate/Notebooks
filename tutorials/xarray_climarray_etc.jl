### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ ce70dae6-7931-11ec-1346-290fae1dfa09
begin
    using Pkg; Pkg.activate()
	
	using ClimateBase, Dates, CairoMakie, PlutoUI
	using PyCall, Conda
	
	#import Pkg
	#ENV["PYTHON"]=""
	#Pkg.build("PyCall")

    #Conda.add("xarray")
    #Conda.add("dask")
    #Conda.add("cftime")

	fil=joinpath(tempdir(),"tas_day_MIROC5_piControl_r1i1p1_20000101-20091231.nc")
	#fil=joinpath(tempdir(),"MXLDEPTH.0011.nc")

	"Done with packages"
end

# ╔═╡ 1efb3af3-141d-4585-ac52-81d8de729d87
md"""## Using xarray from julia via pyCall

- pyimport xarray and call `open_mfdataset`
- access and visualize variable `tas`
- convert to climarray via `climarray_from_xarray`
"""

# ╔═╡ 82a160b0-9e18-4a19-ad0f-0d4128e0f2da
TableOfContents()

# ╔═╡ dfdf8fb4-06f5-47d5-a00b-5ce70c2788d0
md"""## Access and Read Data"""

# ╔═╡ 814763ca-bb56-4fdf-b968-4580084725e5
	time = NCDataset(fil,"r") do ds
    	ds["time"][:]
	end # ds is closed

# ╔═╡ 98985861-7173-44d5-bd64-3d3f1ebe3bfb
md"""## Visualize Data"""

# ╔═╡ 9a290c40-5b7c-420f-881f-6ec5613cd9d3
md"""## Convert to ClimArray

See [ClimateBase.jl](https://juliaclimate.github.io/ClimateBase.jl/dev/) for documentation on the `ClimArray` data structure.
"""

# ╔═╡ 16847075-ce93-44d0-9c64-180944a1dd71
md"""## Appendix"""

# ╔═╡ 2dba3c1a-daa8-4445-8024-12880bd9b53f
begin
	xr = pyimport("xarray")
	np = pyimport("numpy")
end

# ╔═╡ a0377670-f6c1-4514-a0c3-3af25628b892
xa = xr.open_mfdataset(fil,decode_times=false)

# ╔═╡ a2fdde3d-8566-40d0-92e9-aeefe59798c9
xa["tas"]["long_name"]

# ╔═╡ a1818e18-fab9-4640-8d23-bf1e64a7961e
begin
	w = getproperty(xa, Symbol("tas"))
	raw_data = Array(w.values)
	size(raw_data)
end

# ╔═╡ f9febc08-369b-4543-9555-0d42de52caa7
xa.tas

# ╔═╡ bd47d77f-11b7-48c2-a618-75b301dc0594
heatmap(xa.tas.values[:,:,1])

# ╔═╡ f10df069-3bbd-4b43-8217-d2bd577f2075
function extract_dimension_values_xarray(xa, dnames = collect(xa.dims))
    dim_values = []
    dim_attrs = Vector{Any}(fill(nothing, length(dnames)))
    for (i, d) in enumerate(dnames)
        dim_attrs[i] = getproperty(xa, d).attrs
        x = getproperty(xa, d).values
        if d ≠ "time"
            push!(dim_values, x)
#        else
#            # Dates need special handling to be transformed into `DateTime`.
#            dates = [np.datetime_as_string(y)[1:19] for y in x]
#            dates = DateTime.(dates)
#            push!(dim_values, dates)
        end
    end
    return dim_values, dim_attrs
end

# ╔═╡ 85437096-707b-49bf-b83e-9db7a7e4cdf7
extract_dimension_values_xarray(xa, ["lon","lat"])

# ╔═╡ 0d43f6da-4785-4d8b-be1d-4e2199d2d2d0
function create_dims_xarray(dnames, dim_values, dim_attrs)
    true_dims = ClimateBase.to_proper_dimensions(dnames)
    optimal_values = ClimateBase.vector2range.(dim_values)
    out = []
    for i in 1:length(true_dims)
        push!(out, true_dims[i](optimal_values[i]; metadata = dim_attrs[i]))
    end
    return (out...,)
end

# ╔═╡ a48856b1-49ab-4133-aa13-1ad8186c6839
function climarray_from_xarray(xa, fieldname, name = fieldname)
    w = getproperty(xa, Symbol(fieldname))
    raw_data = Array(w.values)

    dnames = collect(w.dims) # dimensions in string name
	length(dnames)>2 ? dnames=dnames[2:3] : nothing
	length(size(raw_data))>2 ? raw_data=raw_data[1,:,:] : nothing
    dim_values, dim_attrs = extract_dimension_values_xarray(xa, dnames)
    #@assert collect(size(raw_data)) == length.(dim_values)
    actual_dims = create_dims_xarray(dnames, dim_values, dim_attrs)
	#actual_dims = [time,actual_dims...]
    ca = ClimArray(raw_data, actual_dims, name; attrib = w.attrs)
end

# ╔═╡ e66fd4ec-0129-48c0-a2a3-d0d924c829f1
lon = climarray_from_xarray(xa, "lon")

# ╔═╡ 96e8ecf3-ca23-4334-bd4b-5f31fcfc3d72
climarray_from_xarray(xa, "tas")

# ╔═╡ Cell order:
# ╟─1efb3af3-141d-4585-ac52-81d8de729d87
# ╟─82a160b0-9e18-4a19-ad0f-0d4128e0f2da
# ╟─dfdf8fb4-06f5-47d5-a00b-5ce70c2788d0
# ╠═a0377670-f6c1-4514-a0c3-3af25628b892
# ╠═e66fd4ec-0129-48c0-a2a3-d0d924c829f1
# ╟─85437096-707b-49bf-b83e-9db7a7e4cdf7
# ╠═814763ca-bb56-4fdf-b968-4580084725e5
# ╠═a2fdde3d-8566-40d0-92e9-aeefe59798c9
# ╠═a1818e18-fab9-4640-8d23-bf1e64a7961e
# ╠═f9febc08-369b-4543-9555-0d42de52caa7
# ╟─98985861-7173-44d5-bd64-3d3f1ebe3bfb
# ╠═bd47d77f-11b7-48c2-a618-75b301dc0594
# ╟─9a290c40-5b7c-420f-881f-6ec5613cd9d3
# ╠═96e8ecf3-ca23-4334-bd4b-5f31fcfc3d72
# ╟─16847075-ce93-44d0-9c64-180944a1dd71
# ╟─ce70dae6-7931-11ec-1346-290fae1dfa09
# ╠═2dba3c1a-daa8-4445-8024-12880bd9b53f
# ╟─f10df069-3bbd-4b43-8217-d2bd577f2075
# ╟─a48856b1-49ab-4133-aa13-1ad8186c6839
# ╟─0d43f6da-4785-4d8b-be1d-4e2199d2d2d0
