#' Step 5: Map ATAC-seq Peaks to Protein-Coding Genes
#'
#' This function identifies which ATAC-seq peaks from the input data overlap with
#' the genomic coordinates of protein-coding genes. It handles potential
#' mismatches in chromosome naming conventions (e.g., 'chr1' vs '1') to
#' ensure accurate mapping.
#'
#' @param granges_list A list containing `gr_expr` (all genes) and `gr_peaks`
#'   (all peaks) as GRanges objects, produced by `create_granges_objects()`.
#'
#' @return A list containing essential mapping information for subsequent steps:
#'   \itemize{
#'     \item `overlaps`: A 'Hits' object detailing which peaks map to which genes.
#'     \item `gtf_pc`: A GRanges object of only the protein-coding genes,
#'       which was used for the mapping.
#'   }
#' @note This function only finds the peak-to-gene mapping. The aggregation
#'   of signals is intentionally left for a later step, after data normalization.
#'
#' @export
map_peaks_to_genes <- function(granges_list) {

  cat("\n--- Step 5: Gene Annotation for ATAC-seq data ---\n")

  # Unpack input objects from the list provided by the previous step
  gr_expr <- granges_list$gr_expr
  gr_peaks <- granges_list$gr_peaks

  # Filter for protein-coding genes only, which we will use as annotation targets
  gtf_pc <- gr_expr[gr_expr$gene_biotype == "protein_coding"]

  # --- FIX: Make chromosome names consistent ---
  # Before finding overlaps, we ensure chromosome names match (e.g., 'chr1').
  # This is a crucial step for accurate mapping.
  seqlevelsStyle(gtf_pc) <- "UCSC"

  # Now, find the overlaps between the ATAC peaks and the protein-coding genes
  overlaps <- findOverlaps(gr_peaks, gtf_pc)

  # Check if we found any overlaps and report to the user
  if (length(overlaps) == 0) {
    warning("No overlaps were found between ATAC peaks and protein-coding genes.")
  } else {
    cat("Success! Found", length(overlaps), "peak-to-gene overlaps.\n")
  }

  cat("Step 5 Complete: Mapping between peaks and genes is ready.\n")

  # We return the overlap information and the set of protein-coding genes
  # for use in the next steps of the analysis.
  return(
    list(
      overlaps = overlaps,
      gtf_pc = gtf_pc
    )
  )
}
