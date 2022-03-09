
using DataFrames, Downloads

function list_notebooks()
    fil=Downloads.download("https://raw.githubusercontent.com/JuliaClimate/Notebooks/master/page/index.md")

    lines=readlines(fil);
    ii=findall( occursin.("[notebook url]",lines) )
    lines=lines[ii]

    sources=["gaelforget" "JuliaClimate" "JuliaOcean" "MarineEcosystemsJuliaCon2021.jl"]
    notebooks=DataFrame("folder" => [], "file" => [], "url" => [])

    for ii in lines
        tmp1=split(ii,"(")
        ii=findall( occursin.("[notebook url]",tmp1) )[1]
        tmp1=tmp1[ii+1]
        tmp1=split(tmp1,")")[1]

        tmp2=split(tmp1,"/")
        test=sum(tmp2[4].==sources)
        if test!==1
            println("Skipping : ")
            println(tmp1)
        end

        push!(notebooks, (tmp2[5], tmp2[end], string(tmp1) ))
    end

    notebooks
end

function download_notebooks(path,notebooks)
    !isdir(path) ? mkdir(path) : nothing
    for i in 1:size(notebooks,1)
        tmp1=joinpath(path,notebooks[i,:folder])
        !isdir(tmp1) ? mkdir(tmp1) : nothing
        tmp2=joinpath(tmp1,notebooks[i,:file])
        try
            Downloads.download(notebooks[i,:url],tmp2)
        catch e
            println("Skipping : ")
            println(tmp2)
        end
    end
end
