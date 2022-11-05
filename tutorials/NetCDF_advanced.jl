### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ 531030c8-a4ec-47fa-b032-8cbe3ba365ea
begin
	using PlutoUI
	"Done with packages."
end

# ╔═╡ a48cb568-f5ac-4f23-9baa-288922e03cdb
md"""# NetCDF : Advanced Topics

This notebook aims to expand upon `NetCDF_basics.jl` by looking at :

- alternate I/O methods (e.g., NetCDF.jl, Zarr.jl, JLD2.jl)
- other array interfaces (e.g., ClimateBase.jl, MeshArrays.jl, DiskArrays.jl, xarray)
- CF-conventions
- benchmarking

!!! warning
    Work in progress -- initial focus is on `benchmarking` with `NCDatasets.jl`.
"""

# ╔═╡ 5dba92dc-2850-49e0-a180-57572b4f9675
TableOfContents()

# ╔═╡ 3e920639-e482-4afd-9044-9dbd6a136f16
md"""## Files for Testing

[This discourse thread](https://discourse.julialang.org/t/help-me-beat-my-pythonist-friends-code-speeding-up-data-reading-with-simple-reduction-from-netcdf-file/76457) provides a benchmarking workflow that reads data from the following files.

```
speeds.nc NetCDF with two 2D variables, not chuncked
direct link: https://ucdavis.box.com/shared/static/yvy3hyvjli45pjroycyxjxs7y7vm61uw.nc 1
speeds_chunked.nc NetCDF with two 2D variables, chunks of 256,256,400
direct link: https://ucdavis.box.com/shared/static/0cvcwld3w9govhv5ijaa1e970c69x0xd.nc 4
speeds.zarr zarr with two 2D variables, chunks of 256,256,400
direct link: https://ucdavis.box.com/shared/static/4g9gtnfg3qsnx4z2f67yf8f76ikkdynh.tar 2
```

!!! warning 
    These files are relatively large (15GB in total) and this is the reason why they are not downloaded by default.

Example code to download the testing files.

```
using Downloads

url="https://ucdavis.box.com/shared/static/yvy3hyvjli45pjroycyxjxs7y7vm61uw.nc"
folder=joinpath(tempdir(),"NetcdfTestCase1")
ncfile=joinpath(folder,"speeds.nc")

!isdir(folder) ? mkdir(folder) : nothing
!isfile(ncfile) ? Downloads.download(url,ncfile) : nothing
```

"""

# ╔═╡ 5db472d3-aa2a-49e1-8249-3c5bf1bf9560
md"""## Simple Implementation

The test workflow proposed in [discourse](https://discourse.julialang.org/t/help-me-beat-my-pythonist-friends-code-speeding-up-data-reading-with-simple-reduction-from-netcdf-file/76457) takes in one file and computes the maximum speed at each time. 

Below is a simple implementation that uses the [NCDatasets.jl](https://alexander-barth.github.io/NCDatasets.jl/latest/) package. The `max_speed` function processes one time slice at a time. It is readily applicable in parallel over multiple cores / workers as explained in the next section.
"""

# ╔═╡ fc7967bd-9ec1-451d-99f2-04656fdd9270
begin
	import NCDatasets as ncd
	folder=joinpath(tempdir(),"NetcdfTestCase1")
	ncfile=joinpath(folder,"speeds.nc")

	#open file
	isfile(ncfile) ? ds=ncd.Dataset(ncfile) : ds=missing

	max_speed(t::Int) = 
		sqrt(maximum((ds["USFC"][:,:,t].^2 .+ ds["VSFC"][:,:,t].^2), dims = (1,2))[1])
#		maximum(sqrt.(ds["USFC"][:,:,t].^2 .+ ds["VSFC"][:,:,t].^2), dims = (1,2))[1]
end

# ╔═╡ b0ee8229-2e75-4146-ab59-003d82058065
md"""Once you have downloaded the file to the adequate location, then the test should proceed. 

Completing the computation may take of the order of 10 to 30 seconds. 

Afterwards we look a parallel methods that speed up computation.
"""

# ╔═╡ b52101ba-483f-4b95-a1cf-44cc0154e8e9
if isfile(ncfile)
	max_speed(1)
	max_speed.(1:2400)
else
	"File not found : $(ncfile)"
end

# ╔═╡ 25dc539f-9001-4b32-b03c-c530354ec6b0
md"""## Benchmarking on Multiple Workers

Here we document the extension of this tutorial to benchmarking with multiple workers. 

See [this discourse thread](https://discourse.julialang.org/t/help-me-beat-my-pythonist-friends-code-speeding-up-data-reading-with-simple-reduction-from-netcdf-file/76457) for more documentation.

**Configuration**

Start Julia with multiple workers, via 

```julia -p auto```

and then enter the following commands in the REPL.

```
@everywhere begin
	import NCDatasets as ncd
	folder=joinpath(tempdir(),"NetcdfTestCase1")
	ds=ncd.Dataset(joinpath(folder,"speeds.nc"))
end
```

**Method 1**

```
@everywhere begin
	max_speed_a(t::Int) = 
		sqrt(maximum((ds["USFC"][:,:,t].^2 .+ ds["VSFC"][:,:,t].^2), dims = (1,2))[1])
#		maximum(sqrt.(ds["USFC"][:,:,t].^2 .+ ds["VSFC"][:,:,t].^2), dims = (1,2))[1]
end
```

**Method 2**

```
@everywhere begin
    tmp=Array{Float32,3}(undef,512,512,1)
    function max_speed_b(t::Int)
        @. tmp = sqrt(ds["USFC"][:,:,t]^2 .+ ds["VSFC"][:,:,t]^2)
        maximum(tmp, dims = (1,2))[1]
    end
end
```

**Timings**

Timings reported below are for an instance of the mybinder instance provided in [JuliaClimate Notebooks]](https://juliaclimate.github.io/Notebooks/#page-top).

On a faster computer, with more CPUs, these numbers would be reduced. 

```
using DistributedArrays

@time max_speed_a.(1:2400)
#26.646342 seconds (297.45 k allocations: 7.043 GiB, 0.84% gc time)

@time max_speed_a.(distribute(collect(1:2400)))
#15.263616 seconds (2.70 M allocations: 148.746 MiB, 0.42% gc time, 11.41% compilation time)

@time max_speed_b.(1:2400)
#18.604244 seconds (299.85 k allocations: 4.700 GiB, 1.01% gc time)

@time max_speed_b.(distribute(collect(1:2400)))
#11.133690 seconds (703 allocations: 88.234 KiB)
```
"""

# ╔═╡ db0508e9-3718-4d49-b325-fe5372fe4265
md"""## Appendix"""


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
NCDatasets = "85f8d34a-cbdd-5861-8df4-14fed0d494ab"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
NCDatasets = "~0.12.8"
PlutoUI = "~0.7.48"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.1"
manifest_format = "2.0"
project_hash = "85f55770d4063e3084627a9d2b9b7724e35a5765"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CFTime]]
deps = ["Dates", "Printf"]
git-tree-sha1 = "ed2e76c1c3c43fd9d0cb9248674620b29d71f2d1"
uuid = "179af706-886a-5703-950a-314cd64e0468"
version = "0.1.2"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "3ca828fe1b75fa84b021a7860bd039eaea84d2f2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.3.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.HDF5_jll]]
deps = ["Artifacts", "JLLWrappers", "LibCURL_jll", "Libdl", "OpenSSL_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "4cc2bb72df6ff40b055295fdef6d92955f9dede8"
uuid = "0234f1f7-429e-5d53-9886-15a909be8d59"
version = "1.12.2+2"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NCDatasets]]
deps = ["CFTime", "DataStructures", "Dates", "NetCDF_jll", "NetworkOptions", "Printf"]
git-tree-sha1 = "1818d54a489492517841c2cb87475ba20918264c"
uuid = "85f8d34a-cbdd-5861-8df4-14fed0d494ab"
version = "0.12.8"

[[deps.NetCDF_jll]]
deps = ["Artifacts", "HDF5_jll", "JLLWrappers", "LibCURL_jll", "Libdl", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "072f8371f74c3b9e1b26679de7fbf059d45ea221"
uuid = "7243133f-43d8-5620-bbf4-c2c921802cf3"
version = "400.902.5+1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6e9dba33f9f2c44e08a020b0caf6903be540004"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.19+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "cceb0257b662528ecdf0b4b4302eb00e767b38e7"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "efc140104e6d0ae3e7e30d56c98c4a927154d684"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.48"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "e59ecc5a41b000fa94423a578d29290c7266fc10"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "58443b63fb7e465a8a7210828c91c08b92132dff"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.14+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─a48cb568-f5ac-4f23-9baa-288922e03cdb
# ╟─5dba92dc-2850-49e0-a180-57572b4f9675
# ╟─3e920639-e482-4afd-9044-9dbd6a136f16
# ╟─5db472d3-aa2a-49e1-8249-3c5bf1bf9560
# ╠═fc7967bd-9ec1-451d-99f2-04656fdd9270
# ╟─b0ee8229-2e75-4146-ab59-003d82058065
# ╠═b52101ba-483f-4b95-a1cf-44cc0154e8e9
# ╟─25dc539f-9001-4b32-b03c-c530354ec6b0
# ╟─db0508e9-3718-4d49-b325-fe5372fe4265
# ╟─531030c8-a4ec-47fa-b032-8cbe3ba365ea
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
