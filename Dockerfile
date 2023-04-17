FROM mas.ops.maap-project.org/root/jupyter-image/vanilla:develop

USER root
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.9/julia-1.9.0-rc2-linux-x86_64.tar.gz && \
    tar -xvzf julia-1.9.0-rc2-linux-x86_64.tar.gz && \
    mv julia-1.9.0-rc2 /opt/ && \
    ln -s /opt/julia-1.9.0-rc2/bin/julia /usr/local/bin/julia && \
    rm julia-1.9.0-rc2-linux-x86_64.tar.gz

ENV mainpath /usr/local/etc/gf
RUN mkdir -p ${mainpath}

COPY ./src ${mainpath}/src
COPY ./src/plutoserver ${mainpath}/plutoserver

RUN cp ${mainpath}/src/setup.py ${mainpath}/setup.py
RUN cp ${mainpath}/src/runpluto.sh ${mainpath}/runpluto.sh
RUN cp ${mainpath}/src/environment.yml ${mainpath}/environment.yml
RUN cp ${mainpath}/src/Project.toml ${mainpath}/Project.toml

ENV JULIA_PROJECT ${mainpath}
ENV JULIA_DEPOT_PATH ${mainpath}/.julia

RUN julia -e "import Pkg; Pkg.Registry.update(); Pkg.instantiate();"

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential && \
    apt-get install -y --no-install-recommends vim && \
    apt-get install -y --no-install-recommends git-all && \
    apt-get install -y --no-install-recommends unzip && \
    apt-get install -y --no-install-recommends gfortran && \
    apt-get install -y --no-install-recommends openmpi-bin && \
    apt-get install -y --no-install-recommends libopenmpi-dev && \
    apt-get install -y --no-install-recommends libnetcdf-dev && \
    apt-get install -y --no-install-recommends libnetcdff-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN jupyter labextension install @jupyterlab/server-proxy && \
    jupyter lab build && \
    jupyter lab clean && \
    pip install ${mainpath} --no-cache-dir && \
    rm -rf ~/.cache

RUN julia ${mainpath}/src/warmup1.jl
RUN julia ${mainpath}/src/download_notebooks.jl

