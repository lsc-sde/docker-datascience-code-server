# https://discourse.jupyter.org/t/how-to-configure-jupyterhub-to-run-code-server/11578/9
# https://github.com/coder/code-server
# https://github.com/betatim/vscode-binder


ARG OWNER=vvcb
ARG BASE_CONTAINER=crlander.azurecr.io/vvcb/datascience-notebook:0.1.0
FROM $BASE_CONTAINER

LABEL maintainer="vvcb"
LABEL image="datascience-code-server"

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Installation des paquets pour le développement
RUN apt-get update --yes && \
    apt-get install --yes --quiet --no-install-recommends \
    curl \
    iputils-ping \
	build-essential \
    make \
    cmake \
    g++ \
    clang \
    htop \
    libopencv-dev \
    && \
    apt-get --quiet clean && rm -rf /var/lib/apt/lists/*

# Installation de Code Server et server-proxy/vscode-proxy pour intégrer Code dans JupyterLab
ENV CODE_VERSION=4.9.0
RUN curl -fOL https://github.com/coder/code-server/releases/download/v$CODE_VERSION/code-server_${CODE_VERSION}_amd64.deb \
    && dpkg -i code-server_${CODE_VERSION}_amd64.deb \
    && rm -f code-server_${CODE_VERSION}_amd64.deb
RUN /opt/conda/bin/conda install -c conda-forge jupyter-server-proxy
RUN /opt/conda/bin/conda install -c conda-forge jupyter-vscode-proxy

# Installation du bureau XFCE et de l'extention Desktop server pour avoir un affichage graphique
RUN apt-get update --yes --quiet && \
    apt-get install --yes --quiet \
    dbus-x11 xfce4 xfce4-panel xfce4-session xfce4-settings xorg xubuntu-icon-theme && \
    apt-get remove --yes --quiet light-locker && \
    apt-get clean --quiet && rm -rf /var/lib/apt/lists/*
RUN /opt/conda/bin/conda install -c manics websockify && \
    pip install git+https://github.com/jupyterhub/jupyter-remote-desktop-proxy.git
 
# Switch back to jovyan to avoid accidental container runs as root
USER ${NB_UID}