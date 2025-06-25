FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Installa R >= 4.3 da CRAN
RUN apt update && apt install -y dirmngr gnupg apt-transport-https ca-certificates software-properties-common && \
    mkdir -p /etc/apt/keyrings && \
    gpg --no-tty --keyserver keyserver.ubuntu.com --recv-key 51716619E084DAB9 && \
    gpg --export 51716619E084DAB9 | tee /etc/apt/keyrings/cran.gpg > /dev/null && \
    echo "deb [signed-by=/etc/apt/keyrings/cran.gpg] https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/" | tee -a /etc/apt/sources.list.d/cran.list && \
    apt update && \
    apt install -y r-base

# Installa librerie di sistema necessarie
RUN apt install -y libcurl4-openssl-dev libssl-dev libxml2-dev wget curl git build-essential

# Installa pacchetti R
RUN R -e "install.packages('Seurat', dependencies=TRUE, repos='https://cloud.r-project.org')"
RUN R -e "setRepositories(ind = 1:3, addURLs = c('https://satijalab.r-universe.dev'))"
RUN R -e "install.packages(c('BPCells', 'presto', 'glmGamPoi', 'ggplot2', 'scales', 'gtable', 'tidyr', 'purrr', 'cpp11', 'SeuratObject'))"
RUN R -e "install.packages('BiocManager')"
RUN R -e 'BiocManager::install(c("remotes", "GenomeInfoDb", "GenomicRanges", "IRanges", "Rsamtools", "S4Vectors", "BiocGenerics"), update = FALSE, ask = FALSE)'
RUN R -e "remotes::install_github('stuart-lab/signac', ref = 'develop')"
RUN R -e "if (!require('Signac')) { stop('Signac package failed to install') } else { message('Signac successfully installed') }"
RUN R -e "remotes::install_github('giorgiascelza/Rproject-analysis')"
WORKDIR /project
CMD ["/bin/bash"]

