#' @details
#' Rproject: A package to analyze 10x multi-omic data.
#' This package provides a set of functions to perform a complete
#' analysis workflow as described in the course project.
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
# Importiamo per intero i pacchetti che causano problemi con @importFrom
#' @import S4Vectors
#' @import SummarizedExperiment
#' @import BiocGenerics
#' @import data.table
#' @import ggplot2

# E usiamo @importFrom per gli altri
#' @importFrom DropletUtils read10xCounts
#' @importFrom GenomicRanges GRanges
#' @importFrom GenomeInfoDb seqlevelsStyle `seqlevelsStyle<-`
#' @importFrom gtools mixedsort
#' @importFrom Matrix t
#' @importFrom methods as
#' @importFrom rtracklayer import
#' @importFrom stats na.omit
#' @importFrom utils write.csv globalVariables
## usethis namespace: end
NULL
