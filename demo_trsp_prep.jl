function trsp_prep(mygrid::gcmgrid,GridVariables::Dict)

    fileName="nctiles_climatology/UVELMASS/UVELMASS"
    U=Main.read_nctiles(fileName,"UVELMASS",mygrid)
    fileName="nctiles_climatology/VVELMASS/VVELMASS"
    V=Main.read_nctiles(fileName,"VVELMASS",mygrid)
    U=mask(U,0.0)
    V=mask(V,0.0)

    fileName="nctiles_climatology/oceTAUX/oceTAUX"
    oceTAUX=Main.read_nctiles(fileName,"oceTAUX",mygrid)
    fileName="nctiles_climatology/oceTAUY/oceTAUY"
    oceTAUY=Main.read_nctiles(fileName,"oceTAUY",mygrid)

    #SSH
    SSH=missing

    TrspX=similar(GridVariables["DXC"])
    TrspY=similar(GridVariables["DYC"])
    TauX=similar(GridVariables["DXC"])
    TauY=similar(GridVariables["DYC"])

    for i=1:mygrid.nFaces
        tmpX=mean(U.f[i],dims=4)
        tmpY=mean(V.f[i],dims=4)
        for k=1:length(GridVariables["RC"])
            tmpX[:,:,k]=tmpX[:,:,k].*GridVariables["DYG"].f[i]
            tmpX[:,:,k]=tmpX[:,:,k].*GridVariables["DRF"][k]
            tmpY[:,:,k]=tmpY[:,:,k].*GridVariables["DXG"].f[i]
            tmpY[:,:,k]=tmpY[:,:,k].*GridVariables["DRF"][k]
        end
        TrspX.f[i]=dropdims(sum(tmpX,dims=3),dims=(3,4))
        TrspY.f[i]=dropdims(sum(tmpY,dims=3),dims=(3,4))
        TauX=mean(oceTAUX.f[i],dims=3)
        TauY=mean(oceTAUY.f[i],dims=3)
    end

    return TrspX, TrspY, TauX, TauY, SSH

end


