# Rproject-analysis
# Rproject: A Complete Workflow for Single-Cell Multi-Omic Analysis

This repository contains the source code for `Rproject`, an R package designed to perform an end-to-end analysis of 10x Genomics single-cell multi-omic (GEX + ATAC) data. The entire workflow is containerized using Docker to ensure full reproducibility.

## Key Features

- **Modular R Package:** All analysis steps are encapsulated in well-documented functions within the `Rproject` package.
- **Reproducible Environment:** A `Dockerfile` is provided to build a complete and consistent computational environment, also available as a pre-built image on Docker Hub.
- **End-to-End Analysis:** The workflow covers data loading, preprocessing, normalization, integration, and visualization.

## How to Replicate the Analysis

To run the complete analysis, you need Docker installed on your machine.

**1. Pull the Docker Image from Docker Hub**

Download the pre-built Docker image containing all necessary software and packages.

```bash
docker pull giorgiascelza/image-seurat-signac:latest
```

**2. Run the Analysis**

The Docker container can be run in two modes:

**A) Interactive Mode (Recommended for exploration)**

This mode gives you access to the container's command line, allowing you to run commands step-by-step.

```bash
# Create a local directory for the results
mkdir -p analysis_results

# Run the container in interactive mode
docker run --rm -it \
  -v "$(pwd)/analysis_results":/project/results \
  giorgiascelza/image-seurat-signac:latest
```
Once inside the container, you can start R and regenerate the report as described in the full vignette.


## Full Documentation (Vignette)

For a detailed, step-by-step walkthrough of the analysis, including all code, outputs, interpretations, and troubleshooting, please refer to the **package vignette**.

The final HTML report, `my_vignette.html`, is the primary documentation and the main output of this project. The source file (`my_vignette.Rmd`) can be found in the `vignettes/` directory of this repository.

## Project Resources

- **GitHub Repository:** [https://github.com/giorgiascelza/Rproject-analysis](https://github.com/giorgiascelza/Rproject-analysis)
- **Docker Hub Image:** [https://hub.docker.com/r/giorgiascelza/image-seurat-signac](https://hub.docker.com/r/giorgiascelza/image-seurat-signac)
