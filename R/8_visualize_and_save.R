#' Step 8: Visualize and Save Results
#'
#' This function generates the final scatter plot comparing gene expression
#' and ATAC signal, and saves all results to the specified folder.
#'
#' @param step7_results A list containing `merged_data` and other results from Step 7.
#' @param output_folder The path to the directory where results will be saved.
#'
#' @return Invisibly returns the path to the main plot file.
#' @export
#'
visualize_and_save <- function(step7_results, output_folder) {

  cat("\n--- Step 8: Visualizing and Saving Results ---\n")

  merged_data <- step7_results$merged_data
  gr_expr_pc <- step7_results$gr_expr_pc # Necessario per ottenere i nomi dei cromosomi

  # --- CONTROLLO DI SICUREZZA ---
  # Controlla se ci sono dati da plottare
  if (is.null(merged_data) || nrow(merged_data) == 0 || all(is.na(merged_data$atac_cpm))) {

    cat("No data available for the final plot. Skipping visualization.\n")

    # Crea un plot vuoto con un messaggio
    p <- ggplot() +
      theme_void() +
      ggtitle("No integrated data to display") +
      labs(subtitle = "The merged dataset was empty or contained no ATAC signal.")

  } else {

    # Aggiungi le informazioni sul cromosoma al dataframe
    gene_coords <- as.data.frame(gr_expr_pc)[, c("gene_id", "seqnames")]
    plot_data <- merge(merged_data, gene_coords, by = "gene_id")

    # Filtra via i geni senza segnale ATAC per il plot principale
    plot_data <- plot_data[!is.na(plot_data$atac_cpm), ]

    # --- SECONDO CONTROLLO DI SICUREZZA ---
    # Controlla di nuovo dopo il filtraggio
    if (nrow(plot_data) == 0) {
      cat("No data with valid ATAC signal found. Skipping visualization.\n")
      p <- ggplot() +
        theme_void() +
        ggtitle("No genes with matched ATAC signal found")

    } else {
      cat(paste("Generating plot for", nrow(plot_data), "genes.\n"))

      # Crea il grafico
      p <- ggplot(plot_data, aes(x = expression_cpm, y = atac_cpm)) +
        geom_point(alpha = 0.5, size = 1) +
        labs(
          title = "Gene Expression vs. Chromatin Accessibility",
          subtitle = "Each point represents a protein-coding gene",
          x = "Gene Expression (log2(CPM+1))",
          y = "Aggregated ATAC Signal (log2(CPM+1))"
        ) +
        theme_bw() +
        # Aggiungi il faceting. Questo ora è sicuro perché plot_data non è vuoto.
        facet_wrap(~seqnames, ncol = 6)
    }
  }

  # Stampa sempre il plot (anche quello vuoto) per l'output della vignette
  print(p)

  # Salva il plot su file
  plot_path <- file.path(output_folder, "expression_vs_atac_plot.png")
  ggsave(plot_path, p, width = 12, height = 8, bg = "white")
  cat("Final plot saved to:", plot_path, "\n")

  # Salva anche le tabelle riassuntive
  summary_unmapped_path <- file.path(output_folder, "summary_unmapped_peaks.csv")
  write.csv(step7_results$summaries_and_plots$summary_unmapped_peaks, summary_unmapped_path, row.names = FALSE)

  summary_no_atac_path <- file.path(output_folder, "summary_genes_no_atac.csv")
  write.csv(step7_results$summaries_and_plots$summary_genes_no_atac, summary_no_atac_path, row.names = FALSE)

  cat("Summary tables saved to:", output_folder, "\n")
  cat("Step 8 Complete.\n")

  return(invisible(plot_path))
}
