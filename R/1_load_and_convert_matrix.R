#' Step 1: Load Data and Convert Matrix
#'
#' This function loads 10x Genomics data and converts the sparse matrix
#' into a full, dense matrix, returning it as a data.table object.
#' It uses `DropletUtils` for safe data loading.
#'
#' @param data_folder Path to the directory containing the 10x Genomics
#'   `filtered_feature_bc_matrix` data.
#'
#' @return A data.table object where rows are features (genes/peaks) and
#'   columns are cells. The first column is named 'feature' and contains
#'   the feature IDs.
#'
#' @export
#' @examples
#' # Find the path to the example 10x matrix data included in the package
#' example_data_dir <- system.file("extdata", "mini_pbmc3k", package = "Rproject")
#'
#' # Run the function on the example data
#' if (dir.exists(example_data_dir)) {
#'   example_dt <- load_and_convert_matrix(data_folder = example_data_dir)
#'   # Display the first few rows and columns of the output
#'   print(example_dt[1:5, 1:5])
#' }
load_and_convert_matrix <- function(data_folder) {

  cat("--- Step 1: Loading Data and Converting Matrix ---\n")

  # Use read10xCounts for safe and easy loading. It returns a
  # SingleCellExperiment object which holds the matrix and feature info together.
  sce <- read10xCounts(data_folder, col.names = TRUE)

  # Estraiamo la matrice di conteggi e i dati delle righe (feature)
  sparse_matrix <- counts(sce)
  feature_data <- rowData(sce)

  # The feature IDs are correctly stored in the rowData
  rownames(sparse_matrix) <- feature_data$ID

  # Convert the sparse matrix to a full matrix
  full_matrix <- as(sparse_matrix, "matrix")

  # Convert to a data.table, keeping the feature IDs as a dedicated column.
  dt_matrix <- as.data.table(full_matrix, keep.rownames = "feature")

  cat("Step 1 Complete: Data loaded and converted to data.table.\n")

  # return the created object for the next step in the pipeline.
  return(dt_matrix)
}
