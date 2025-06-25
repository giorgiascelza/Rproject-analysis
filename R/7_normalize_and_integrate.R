#' Step 7: Normalize, Integrate, and Analyze Unmerged Data
#'
#' This function performs a series of core analysis tasks:
#' 1. Normalizes both expression and ATAC data using the CPM method.
#' 2. Aggregates the normalized ATAC signal at the gene level.
#' 3. Merges the two modalities into a single data frame.
#' 4. Generates summary tables and plots for features that could not be integrated.
#'
#' @param data_list A list containing the raw `expression` and `peaks` data.tables.
#' @param annotated_list A list containing `gr_expr_pc`, `gr_peaks`, e `overlaps`.
#'
#' @return A list containing the results needed for the final visualization:
#'   \itemize{
#'     \item `merged_data`: The main data frame with integrated, normalized data.
#'     \item `gr_expr_pc`: The GRanges object for protein-coding genes (passed through for Step 8).
#'     \item `summaries_and_plots`: A nested list containing the summary tables and plots.
#'   }
#' @export
#'
normalize_and_integrate <- function(data_list, annotated_list) {

  cat("\n--- Step 7: Normalizing and Integrating Data ---\n")

  # --- Unpack all necessary input objects ---
  expression_dt <- data_list$expression
  peaks_dt <- data_list$peaks
  gr_expr_pc <- annotated_list$gr_expr_pc
  gr_peaks <- annotated_list$gr_peaks
  overlaps <- annotated_list$overlaps

  # --- CPM Normalization Function ---
  normalize_cpm_log2 <- function(counts) {
    col_sums <- colSums(counts)
    col_sums[col_sums == 0] <- 1
    cpm <- sweep(counts, 2, col_sums, FUN = "/") * 1e6
    return(log2(cpm + 1))
  }

  # Normalize the count matrices
  cat("Normalizing expression and ATAC count matrices...\n")
  pc_gene_ids <- gr_expr_pc$gene_id
  norm_expr_matrix <- normalize_cpm_log2(as.matrix(expression_dt[feature %in% pc_gene_ids, -'feature']))
  norm_atac_matrix <- normalize_cpm_log2(as.matrix(peaks_dt[, -'feature']))

  mean_norm_expr <- rowMeans(norm_expr_matrix)
  names(mean_norm_expr) <- expression_dt[feature %in% pc_gene_ids, feature]
  mean_norm_atac <- rowMeans(norm_atac_matrix)
  names(mean_norm_atac) <- peaks_dt$feature

  # Aggregate the NORMALIZED ATAC signal by gene
  cat("Aggregating normalized ATAC signal by gene...\n")
  gtf_pc_for_mapping <- gr_expr_pc
  seqlevelsStyle(gtf_pc_for_mapping) <- "UCSC"

  norm_atac_annotation_dt <- data.table(
    gene_id = mcols(gtf_pc_for_mapping)$gene_id[subjectHits(overlaps)],
    norm_peak_signal = mean_norm_atac[queryHits(overlaps)]
  )
  norm_atac_aggregated_by_gene <- norm_atac_annotation_dt[, .(atac_cpm = sum(norm_peak_signal)), by = gene_id]

  # Merge expression and ATAC data
  expr_df <- data.frame(gene_id = names(mean_norm_expr), expression_cpm = mean_norm_expr)
  atac_df <- as.data.frame(norm_atac_aggregated_by_gene)
  merged_data <- merge(expr_df, atac_df, by = "gene_id", all.x = TRUE)
  cat("Expression and ATAC data merged.\n")

  # --- Analysis of Unmerged Data ---
  cat("Analyzing unmerged features...\n")

  # =========================================================================
  # FIX: Use seq_along() instead of 1:length() to handle the edge case of
  # zero-length objects correctly.
  # =========================================================================
  unmapped_peak_indices <- setdiff(seq_along(gr_peaks), unique(queryHits(overlaps)))

  summary_unmapped_peaks <- data.table(
    Total_Peaks = length(gr_peaks),
    Mapped_Peaks = length(unique(queryHits(overlaps))),
    Unmapped_Peaks = length(unmapped_peak_indices)
  )

  # Initialize plot and data frame to avoid errors if there are no unmapped peaks
  plot_unmapped_peaks <- ggplot() + theme_void() + ggtitle("No unmapped peaks to plot")

  # --- Add a defensive check ---
  if (length(unmapped_peak_indices) > 0) {
    # This line is now safe
    unmapped_peaks_gr <- gr_peaks[unmapped_peak_indices]

    plot_unmapped_df <- as.data.frame(unmapped_peaks_gr)
    plot_unmapped_peaks <- ggplot(plot_unmapped_df, aes(x = seqnames, y = log10(total_accessibility + 1))) +
      geom_boxplot() +
      labs(title = "Intensity of Unmapped ATAC Peaks by Chromosome", x = "Chromosome", y = "Log10(Total Accessibility + 1)") +
      theme_bw() + theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
  }

  genes_no_atac <- merged_data[is.na(merged_data$atac_cpm), ]
  gene_coords_for_plot <- as.data.frame(gr_expr_pc)[, c("gene_id", "seqnames")]
  genes_no_atac_for_plot <- merge(genes_no_atac, gene_coords_for_plot, by="gene_id")
  summary_genes_no_atac <- data.table(
    Total_PC_Genes_in_Expr = nrow(expr_df),
    Genes_with_ATAC_signal = nrow(merged_data) - nrow(genes_no_atac),
    Genes_without_ATAC_signal = nrow(genes_no_atac)
  )

  # Initialize plot
  plot_genes_no_atac <- ggplot() + theme_void() + ggtitle("No genes without ATAC signal to plot")

  if(nrow(genes_no_atac_for_plot) > 0) {
    plot_genes_no_atac <- ggplot(genes_no_atac_for_plot, aes(x = seqnames, y = expression_cpm)) +
      geom_boxplot() +
      labs(title = "Expression of Genes without ATAC Signal by Chromosome", x = "Chromosome", y = "Expression (log2(CPM+1))") +
      theme_bw() + theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
  }

  cat("Step 7 Complete.\n")

  return(
    list(
      merged_data = merged_data,
      gr_expr_pc = gr_expr_pc,
      summaries_and_plots = list(
        summary_unmapped_peaks = summary_unmapped_peaks,
        summary_genes_no_atac = summary_genes_no_atac,
        plot_unmapped_peaks = plot_unmapped_peaks,
        plot_genes_no_atac = plot_genes_no_atac
      )
    )
  )
}
