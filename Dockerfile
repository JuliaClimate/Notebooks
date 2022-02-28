FROM jupyter/base-notebook:latest

USER root
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.7/julia-1.7.2-linux-x86_64.tar.gz && \
    tar -xvzf julia-1.7.2-linux-x86_64.tar.gz && \
    mv julia-1.7.2 /opt/ && \
    ln -s /opt/julia-1.7.2/bin/julia /usr/local/bin/julia && \
    rm julia-1.7.2-linux-x86_64.tar.gz

USER ${NB_USER}

COPY --chown=${NB_USER}:users ./plutoserver ./plutoserver
COPY --chown=${NB_USER}:users ./sysimage ./sysimage

RUN cp ./sysimage/environment.yml ./environment.yml
RUN cp ./sysimage/setup.py ./setup.py
RUN cp ./sysimage/runpluto.sh ./runpluto.sh
 
ßCOPY --chown=${NB_USER}:users ./Project.toml ./Project.toml

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

USER ${NB_USER}

RUN jupyter labextension install @jupyterlab/server-proxy && \
    jupyter lab build && \
    jupyter lab clean && \
    pip install . --no-cache-dir && \
    rm -rf ~/.cache
RUN julia --project=./ -e "import Pkg; Pkg.instantiate();"
RUN julia sysimage/download_stuff.jl
RUN julia sysimage/create_sysimage.jl
RUN julia --sysimage ExampleSysimage.so sysimage/pre_build_models.jl
