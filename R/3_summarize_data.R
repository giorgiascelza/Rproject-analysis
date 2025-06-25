#' Step 3: Summarize Data by Feature
#'
#' This function computes the total count for each feature (gene or peak) across
#' all cells. It takes a list of data.tables (one for expression, one for peaks)
#' and calculates the row-wise sum for each.
#'
#' @param data_list A list containing two data.tables: `expression` and `peaks`,
#'   as produced by `split_data()`.
#'
#' @return A list containing two named numeric vectors:
#'   \itemize{
#'     \item `gene_totals`: A vector of total expression per gene.
#'     \item `peak_totals`: A vector of total accessibility per peak.
#'   }
#'
#' @export
#'
summarize_data <- function(data_list) {

  cat("\n--- Step 3: Summarizing Data (Row-wise Sums) ---\n")

  # --- For Gene Expression Data ---
  expression_dt <- data_list$expression
  # Select all columns EXCEPT the 'feature' column for the sum.
  total_expression_per_gene <- rowSums(expression_dt[, -'feature'])
  # Assign the feature IDs as names to the resulting vector
  names(total_expression_per_gene) <- expression_dt$feature

  # --- For ATAC-seq Peak Data ---
  peaks_dt <- data_list$peaks
  total_accessibility_per_peak <- rowSums(peaks_dt[, -'feature'])
  names(total_accessibility_per_peak) <- peaks_dt$feature

  # Print summaries to the console for the user
  cat("Summary of total expression per gene:\n")
  print(summary(total_expression_per_gene))
  cat("\nSummary of total accessibility per peak:\n")
  print(summary(total_accessibility_per_peak))

  cat("Step 3 Complete: Row-wise sums calculated.\n")

  # Return the two vectors in a named list
  return(
    list(
      gene_totals = total_expression_per_gene,
      peak_totals = total_accessibility_per_peak
    )
  )
}
