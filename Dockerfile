FROM jupyter/base-notebook:latest

USER root

ENV mainpath ./
RUN mkdir -p ${mainpath}

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential && \
    apt-get install -y --no-install-recommends vim && \
    apt-get install -y --no-install-recommends curl && \
    apt-get install -y --no-install-recommends git-all && \
    apt-get install -y --no-install-recommends unzip && \
    apt-get install -y --no-install-recommends gfortran && \
    apt-get install -y --no-install-recommends openmpi-bin && \
    apt-get install -y --no-install-recommends libopenmpi-dev && \
    apt-get install -y --no-install-recommends libnetcdf-dev && \
    apt-get install -y --no-install-recommends libnetcdff-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER ${NB_USER}

RUN echo 'alias julia="${mainpath}/.juliaup/bin/julia --project=${mainpath}"' >> ~/.bashrc
RUN curl -fsSL https://install.julialang.org | sh -s -- --yes

COPY --chown=${NB_USER}:users ./src ${mainpath}/src
COPY --chown=${NB_USER}:users ./src/plutoserver ${mainpath}/plutoserver

RUN cp ${mainpath}/src/setup.py ${mainpath}/setup.py
RUN cp ${mainpath}/src/runpluto.sh ${mainpath}/runpluto.sh
RUN cp ${mainpath}/src/environment.yml ${mainpath}/environment.yml
RUN cp ${mainpath}/src/Project.toml ${mainpath}/Project.toml

RUN ${mainpath}/.juliaup/bin/julia --project=${mainpath} -e "import Pkg; Pkg.update(); Pkg.instantiate();"

RUN jupyter lab build && \
    jupyter lab clean && \
    pip install ${mainpath} --no-cache-dir && \
    rm -rf ~/.cache

RUN ${mainpath}/.juliaup/bin/julia ${mainpath}/src/warmup1.jl
RUN ${mainpath}/.juliaup/bin/julia ${mainpath}/src/download_notebooks.jl

RUN mkdir .dev
RUN mv build plutoserver.egg-info .dev

