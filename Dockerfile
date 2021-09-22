FROM jupyter/base-notebook:latest

USER root
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.7/julia-1.7.0-rc1-linux-x86_64.tar.gz && \
    tar -xvzf julia-1.7.0-rc1-linux-x86_64.tar.gz && \
    mv julia-1.7.0-rc1 /opt/ && \
    ln -s /opt/julia-1.7.0-rc1/bin/julia /usr/local/bin/julia && \
    rm julia-1.7.0-rc1-linux-x86_64.tar.gz

USER ${NB_USER}

COPY --chown=${NB_USER}:users ./plutoserver ./plutoserver
COPY --chown=${NB_USER}:users ./sysimage ./sysimage

RUN cp ./sysimage/environment.yml ./environment.yml
RUN cp ./sysimage/setup.py ./setup.py
RUN cp ./sysimage/runpluto.sh ./runpluto.sh
 
COPY --chown=${NB_USER}:users ./OceanTransports ./OceanTransports
COPY --chown=${NB_USER}:users ./DataStructures ./DataStructures
COPY --chown=${NB_USER}:users ./inputs ./inputs
COPY --chown=${NB_USER}:users ./outputs ./outputs
COPY --chown=${NB_USER}:users ./Project.toml ./Project.toml

ENV USER_HOME_DIR /home/${NB_USER}
ENV JULIA_PROJECT ${USER_HOME_DIR}
ENV JULIA_DEPOT_PATH ${USER_HOME_DIR}/.julia
WORKDIR ${USER_HOME_DIR}

RUN julia -e "import Pkg; Pkg.Registry.update(); Pkg.instantiate();"

USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential && \
    apt-get install -y --no-install-recommends gfortran && \
    apt-get install -y --no-install-recommends libnetcdf-dev && \
    apt-get install -y --no-install-recommends libnetcdff-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
RUN julia sysimage/create_sysimage.jl

USER ${NB_USER}

RUN jupyter labextension install @jupyterlab/server-proxy && \
    jupyter lab build && \
    jupyter lab clean && \
    pip install . --no-cache-dir && \
    rm -rf ~/.cache
RUN julia sysimage/pre_build_models.jl
