% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/5_map_peaks_to_genes.R
\name{map_peaks_to_genes}
\alias{map_peaks_to_genes}
\title{Step 5: Map ATAC-seq Peaks to Protein-Coding Genes}
\usage{
map_peaks_to_genes(granges_list)
}
\arguments{
\item{granges_list}{A list containing `gr_expr` (all genes) and `gr_peaks`
(all peaks) as GRanges objects, produced by `create_granges_objects()`.}
}
\value{
A list containing essential mapping information for subsequent steps:
  \itemize{
    \item `overlaps`: A 'Hits' object detailing which peaks map to which genes.
    \item `gtf_pc`: A GRanges object of only the protein-coding genes,
      which was used for the mapping.
  }
}
\description{
This function identifies which ATAC-seq peaks from the input data overlap with
the genomic coordinates of protein-coding genes. It handles potential
mismatches in chromosome naming conventions (e.g., 'chr1' vs '1') to
ensure accurate mapping.
}
\note{
This function only finds the peak-to-gene mapping. The aggregation
  of signals is intentionally left for a later step, after data normalization.
}
