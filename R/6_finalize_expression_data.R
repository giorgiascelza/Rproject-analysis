#' Step 6: Finalize Expression Data
#'
#' This function takes the set of protein-coding genes identified in the previous
#' step and performs final preparations, such as renaming metadata columns for
#' clarity (e.g., from 'gene_name' to 'gene_symbol').
#'
#' @param mapping_list A list containing `gtf_pc`, the GRanges object for
#'   protein-coding genes, as produced by `map_peaks_to_genes()`.
#'
#' @return A finalized GRanges object (`gr_expr_pc`) containing only
#'   protein-coding genes, ready for the normalization step.
#'
#' @export
#'
finalize_expression_data <- function(mapping_list) {

  cat("\n--- Step 6: Finalizing Expression Data ---\n")

  # The set of protein-coding genes was already filtered in the previous step.
  # We take it as input.
  gr_expr_pc <- mapping_list$gtf_pc

  # The gene symbol is already in the metadata column `gene_name`.
  # We rename it for clarity, as requested.
  if ("gene_name" %in% names(mcols(gr_expr_pc))) {
    # Per modificare i nomi, assegniamo un nuovo vettore di nomi
    current_names <- names(mcols(gr_expr_pc))
    current_names[current_names == "gene_name"] <- "gene_symbol"
    names(mcols(gr_expr_pc)) <- current_names

    cat("Renamed metadata column 'gene_name' to 'gene_symbol'.\n")
  }

  cat("Step 6 Complete: Expression data is finalized.\n")

  # Return the finalized GRanges object
  return(gr_expr_pc)
}
