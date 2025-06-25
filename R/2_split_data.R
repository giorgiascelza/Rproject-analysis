#' Step 2: Split Gene Expression and ATAC-seq Data
#'
#' This function takes a data.table of mixed features and separates it into
#' two distinct data.tables: one for gene expression data (features starting
#' with 'ENSG') and one for ATAC-seq peak data (features starting with 'chr').
#'
#' @param dt_matrix A data.table produced by `load_and_convert_matrix`,
#'   containing a column named 'feature'.
#'
#' @return A list containing two named data.table objects:
#'   \itemize{
#'     \item `expression`: A data.table with only gene expression features.
#'     \item `peaks`: A data.table with only ATAC-seq peak features.
#'   }
#'
#' @export
#'
split_data <- function(dt_matrix) {

  cat("\n--- Step 2: Split Gene Expression and ATAC-seq Data ---\n")

  # The input data.table has a 'feature' column which we use for filtering.
  # The grep function is used to find patterns at the beginning of the feature names.
  expression_dt <- dt_matrix[grepl("^ENSG", feature)]
  peaks_dt <- dt_matrix[grepl("^chr", feature)]

  # Print summary messages to the console
  cat("Number of gene expression features:", nrow(expression_dt), "\n")
  cat("Number of ATAC-seq peak features:", nrow(peaks_dt), "\n")
  cat("Step 2 Complete: Data has been split.\n")

  # Return the two new data.tables in a named list for the next step
  return(
    list(
      expression = expression_dt,
      peaks = peaks_dt
    )
  )
}
