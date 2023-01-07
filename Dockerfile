FROM jupyter/base-notebook:latest

USER root

ENV JULIA_NAME "julia-1.9.0-beta2-linux-x86_64.tar.gz"
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.9/${JULIA_NAME} && \
    tar -xvzf ${JULIA_NAME} && \
    mv julia-1.9.0-beta2 /opt/ && \
    ln -s /opt/julia-1.9.0-beta2/bin/julia /usr/local/bin/julia && \
    rm ${JULIA_NAME}

ENV mainpath ./
RUN mkdir -p ${mainpath}

USER ${NB_USER}

COPY --chown=${NB_USER}:users ./src ${mainpath}/src
COPY --chown=${NB_USER}:users ./src/plutoserver ${mainpath}/plutoserver

RUN cp ${mainpath}/src/setup.py ${mainpath}/setup.py
RUN cp ${mainpath}/src/runpluto.sh ${mainpath}/runpluto.sh
RUN cp ${mainpath}/src/environment.yml ${mainpath}/environment.yml
RUN cp ${mainpath}/src/Project.toml ${mainpath}/Project.toml

ENV USER_HOME_DIR /home/${NB_USER}
ENV JULIA_PROJECT ${USER_HOME_DIR}
ENV JULIA_DEPOT_PATH ${USER_HOME_DIR}/.julia

RUN julia --project=${mainpath} -e "import Pkg; Pkg.update(); Pkg.instantiate(); Pkg.precompile()"

USER root

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

USER ${NB_USER}

RUN jupyter labextension install @jupyterlab/server-proxy && \
    jupyter lab build && \
    jupyter lab clean && \
    pip install ${mainpath} --no-cache-dir && \
    rm -rf ~/.cache

RUN mkdir .dev
RUN mv build plutoserver.egg-info .dev
