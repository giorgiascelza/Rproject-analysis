#' Step 4: Create GenomicRanges Objects
#'
#' This function takes summarized count vectors for genes and peaks and
#' converts them into GenomicRanges objects. It uses a GTF annotation file
#' to assign genomic coordinates to the genes.
#'
#' @param summary_list A list containing `gene_totals` and `peak_totals` vectors,
#'   as produced by `summarize_data()`.
#' @param gtf_file_path Path to the `Homo_sapiens.GRCh38.114.gtf.gz` annotation file,
#'   or a smaller version for examples.
#'
#' @return A list containing two named GenomicRanges objects:
#'   \itemize{
#'     \item `gr_expr`: A GRanges object for genes, with expression totals as metadata.
#'     \item `gr_peaks`: A GRanges object for peaks, with accessibility totals as metadata.
#'   }
#'
#' @export
#' @examples
#' # This example demonstrates how to use this function as part of the
#' # full workflow, using the example data included in the package.
#'
#' # First, find the paths to the example data using system.file()
#' example_data_dir <- system.file("extdata", "mini_pbmc3k", package = "Rproject")
#' example_gtf_path <- system.file("extdata", "mini_annotation.gtf.gz", package = "Rproject")
#'
#' # Check if the example data exists before running
#' if (dir.exists(example_data_dir) && file.exists(example_gtf_path)) {
#'
#'   # --- Run previous steps to generate the necessary input ---
#'   # Step 1 -> 3:
#'   dt_matrix_sample <- load_and_convert_matrix(example_data_dir)
#'   data_list_sample <- split_data(dt_matrix_sample)
#'   summary_list_sample <- summarize_data(data_list_sample)
#'
#'   # --- Now, run the function we are demonstrating (Step 4) ---
#'   granges_list <- create_granges_objects(
#'     summary_list = summary_list_sample,
#'     gtf_file_path = example_gtf_path
#'   )
#'
#'   # Display the structure of the output
#'   print(granges_list)
#' }
create_granges_objects <- function(summary_list, gtf_file_path) {

  cat("\n--- Step 4: Creating GenomicRanges Objects ---\n")

  # Unpack the input list
  total_expression_per_gene <- summary_list$gene_totals
  total_accessibility_per_peak <- summary_list$peak_totals

  # Load GTF annotation file
  cat("Loading GTF file for gene coordinates...\n")
  gtf <- import(gtf_file_path)
  # We only need the 'gene' features from the GTF
  gtf_genes <- gtf[gtf$type == "gene"]
  names(gtf_genes) <- gtf_genes$gene_id

  # 1. Create GRanges for ATAC-seq peaks
  cat("Creating GRanges for ATAC-seq peaks...\n")
  gr_peaks <- GRanges(seqnames = names(total_accessibility_per_peak))
  # Add the summarized data as metadata
  mcols(gr_peaks)$total_accessibility <- total_accessibility_per_peak

  # 2. Create GRanges for Gene Expression
  cat("Creating GRanges for gene expression...\n")
  genes_in_data <- names(total_expression_per_gene)
  gr_expr <- gtf_genes[names(gtf_genes) %in% genes_in_data]
  # Add the summarized expression data, ensuring the order is correct
  gr_expr$total_expression <- total_expression_per_gene[names(gr_expr)]

  cat("Step 4 Complete: Biologically meaningful GenomicRanges objects created.\n")

  # Return the two GRanges objects in a named list for the next steps
  return(
    list(
      gr_expr = gr_expr,
      gr_peaks = gr_peaks
    )
  )
}
