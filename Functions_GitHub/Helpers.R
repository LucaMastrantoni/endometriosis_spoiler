# Functions shared by the notebooks. Sourced by Setup.R.

# ==== Saving results ===========================================================

# Folder of a figure panel under `root`, from its name: "Figure2c" ->
# Main/Figure2, "FigureS6b" -> Supplementary/FigureS6. Created if missing.
figure_folder <- function(root, name) {
  figure <- regmatches(name, regexpr("^FigureS?[0-9]+", name))
  stopifnot(length(figure) == 1)
  dir <- file.path(root, if (startsWith(figure, "FigureS")) "Supplementary" else "Main", figure)
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  dir
}

# Save a plot in one call. The device is chosen from the file extension
# (svg, pdf, png, jpg/jpeg); `file` is a figure file name such as
# "Figure2c.svg", saved in ../OUTPUT/FIGURES/Main/Figure2 (see figure_folder()).
# SVGs are written with svglite (editable text; the Cairo svg() device uses
# filter compositing that PowerPoint draws wrongly), made fully vector with
# vectorise_svg_images(), and always get a 300 dpi PNG copy.
# Panel-letter font size for a figure exported `width` inches wide, so the letter prints bold at `pt` once
# the figure is fitted to the 540 pt page width (the size of the main-figure letters)
letter_size <- function(width, pt = 12) pt * width * 72 / 540

save_plot <- function(plot, file, width, height, res = 600) {
  path <- file.path(figure_folder(path_figures, file), file)
  ext <- tolower(tools::file_ext(file))
  switch(ext,
         svg  = svglite::svglite(path, width = width, height = height),
         pdf  = pdf(path, width = width, height = height),
         png  = png(path, width = width, height = height, units = "in", res = res),
         jpg  = ,
         jpeg = jpeg(path, width = width, height = height, units = "in", res = res),
         stop("Unsupported figure format: ", file))
  tryCatch(if (inherits(plot, "grob")) grid::grid.draw(plot) else print(plot),
           finally = dev.off())
  if (ext == "svg") {
    vectorise_svg_images(path)
    transparent_svg_background(path)
    save_plot(plot, sub("\\.svg$", ".png", file), width, height, res = 300)
  }
  invisible(path)
}

# Replace the small raster images of an SVG (colour bars are drawn as a 1 x 300
# pixel image) with one vector rectangle per pixel, so that the file is fully
# vector. Images with more than `max_pixels` pixels are left as they are.
vectorise_svg_images <- function(file, max_pixels = 5000) {
  x <- readLines(file, warn = FALSE)
  attr_of <- function(tag, name) {
    m <- regmatches(tag, regexec(paste0("\\s", name, "='([^']*)'"), tag))[[1]]
    if (length(m)) m[2] else NA_character_
  }
  for (i in grep("<image ", x)) {
    tag <- regmatches(x[i], regexpr("<image [^>]*/>", x[i]))
    href <- if (length(tag)) attr_of(tag, "xlink:href") else NA
    if (is.na(href) || !startsWith(href, "data:image/png;base64,")) next
    px <- png::readPNG(base64enc::base64decode(sub("^data:image/png;base64,", "", href)))
    if (length(dim(px)) == 2) px <- array(px, c(dim(px), 1))
    h <- dim(px)[1]; w <- dim(px)[2]
    if (w * h > max_pixels) next
    X <- as.numeric(attr_of(tag, "x")); Y <- as.numeric(attr_of(tag, "y"))
    dw <- as.numeric(attr_of(tag, "width")) / w; dh <- as.numeric(attr_of(tag, "height")) / h
    rects <- character(0)
    for (r in seq_len(h)) for (c in seq_len(w)) {
      v <- px[r, c, ]
      if (length(v) <= 2) v <- c(rep(v[1], 3), v[2])  # grey (+ alpha)
      alpha <- if (length(v) == 4 && !is.na(v[4])) v[4] else 1
      # opaque rectangles extend one pixel under the next one, to avoid hairline seams
      grow <- alpha == 1
      rects <- c(rects, sprintf("<rect x='%.3f' y='%.3f' width='%.3f' height='%.3f' style='stroke: none; fill: %s;%s'/>",
                                X + (c - 1) * dw, Y + (r - 1) * dh, dw * (1 + grow * (c < w)), dh * (1 + grow * (r < h)),
                                grDevices::rgb(v[1], v[2], v[3]),
                                if (alpha < 1) sprintf(" fill-opacity: %.3f;", alpha) else ""))
    }
    # the image's other attributes (clip-path, transform) go on a group
    other <- gsub("\\s(width|height|x|y|preserveAspectRatio|xlink:href|image-rendering)='[^']*'", "", tag)
    other <- trimws(sub("/>$", "", sub("^<image", "", other)))
    x[i] <- sub("<image [^>]*/>", paste0("<g", if (nzchar(other)) paste0(" ", other), ">",
                                          paste(rects, collapse = ""), "</g>"), x[i])
  }
  writeLines(x, file)
}

# Remove the white page and plot backgrounds of an SVG (svglite canvas and ggplot
# plot.background), so that panels overlapping in the assembled figures do not
# hide each other. Panel and legend backgrounds are kept.
transparent_svg_background <- function(file) {
  x <- readLines(file, warn = FALSE)
  x <- gsub("<rect width='100%' height='100%' style='stroke: none; fill: #FFFFFF;'/>", "", x, fixed = TRUE)
  x <- gsub("<rect [^>]*style='stroke-width: [0-9.]+; stroke: #FFFFFF; fill: #FFFFFF;' />", "", x)
  writeLines(x, file)
}

# Write one or more tables to an Excel workbook in ../OUTPUT/TABLES (one sheet per
# list element). Row names (gene symbols for topTable output) become the first
# column, named `rownames_to`; use rownames_to = NULL to drop them.
save_tables <- function(tables, file, rownames_to = "Gene") {
  if (is.data.frame(tables)) tables <- list(Sheet1 = tables)
  if (!is.null(rownames_to)) {
    tables <- lapply(tables, function(x) tibble::rownames_to_column(as.data.frame(x), rownames_to))
  }
  openxlsx::write.xlsx(tables, file.path(path_tables, file))
  invisible(file)
}

# Source data of one figure panel, written to ../OUTPUT/Excel Files/<folder>/<panel>.xlsx
# (panel named as its figure file, e.g. "Figure2c", "FigureS6b"; folder as for
# the figures); one sheet per list element. Row names become the first column
# `rownames_to` (NULL drops them).
save_source_data <- function(tables, panel, rownames_to = NULL) {
  if (is.data.frame(tables) || is.matrix(tables)) tables <- list(Sheet1 = tables)
  tables <- lapply(tables, function(x) {
    x <- as.data.frame(x, check.names = FALSE)
    if (!is.null(rownames_to)) x <- tibble::rownames_to_column(x, rownames_to)
    rownames(x) <- NULL
    x
  })
  openxlsx::write.xlsx(tables, file.path(figure_folder(path_source, panel), paste0(panel, ".xlsx")))
  invisible(panel)
}

# Data plotted by plot_volcano(): statistics of all genes of the topTable, the
# y value and the genes labelled on the plot (annotation columns are in the
# full tables of ../OUTPUT/TABLES)
volcano_source <- function(volcano) {
  volcano$data %>%
    dplyr::select(Gene = gene, any_of(c("GeneID", "logFC", "AveExpr", "t", "P.Value", "adj.P.Val", "B")),
                  `-log10 FDR` = negLog10FDR, label) %>%
    mutate(Labelled = label != "") %>%
    dplyr::select(-label)
}

# Significant gene sets of a GSEA (or ORA) result; `Shown` marks the first
# `show` rows, the ones drawn by dotplot()/plot_gsea()/cnetplot().
# as.data.frame() applies the p/q-value cutoffs of ORA results, as the plots do.
gsea_source <- function(gsea, show = 30) {
  res <- as.data.frame(gsea)
  rownames(res) <- NULL
  cbind(Shown = seq_len(nrow(res)) <= show, res)
}

# Save all objects of the notebook being knitted (data, models, plots) to
# ../OUTPUT/RData/<notebook>.RData. To change a figure without re-running:
# source("Setup.R"); load("../OUTPUT/RData/<notebook>.RData"); edit; save_plot(...)
save_workspace <- function(envir = parent.frame()) {
  name <- sub("\\..*$", "", basename(knitr::current_input()))
  save(list = ls(envir = envir, all.names = TRUE), envir = envir,
       file = file.path(path_rdata, paste0(name, ".RData")))
}

# ==== Data objects =============================================================

# SpatialExperiment (standR) from the gene-level GeoMx object of 01_Preprocessing.
# Extra arguments go to readGeoMx.
geomx_to_spe <- function(target_demoData, ...) {
  countFile <- assayData(target_demoData)[["exprs"]] %>%
    as.data.frame() %>%
    rownames_to_column("TargetName")
  sampleAnnoFile <- pData(target_demoData) %>%
    as.data.frame() %>%
    rownames_to_column("SegmentDisplayName")
  featureAnnoFile <- fData(target_demoData) %>%
    as.data.frame()
  rownames(featureAnnoFile) <- NULL

  # Placeholder coordinates (required by readGeoMx, not used)
  sampleAnnoFile$ROICoordinateX <- seq(1, nrow(sampleAnnoFile), 1)
  sampleAnnoFile$ROICoordinateY <- seq(1, nrow(sampleAnnoFile), 1)

  readGeoMx(countFile, sampleAnnoFile, featureAnnoFile, ...)
}

# Patient and scan get short labels (Pt_01.., Scan_01..) numbered by first
# appearance, and `biology` (Category_Segment) is the factor kept by RUV4.
add_sample_labels <- function(spe) {
  col_data <- as.data.frame(spe@colData)
  scan_ids <- unique(col_data$Scan_ID)
  patient_ids <- unique(col_data$Patient_ID)
  spe@colData$Scan <- paste0("Scan_", sprintf("%02d", match(col_data$Scan_ID, scan_ids)))
  spe@colData$Patient <- paste0("Pt_", sprintf("%02d", match(col_data$Patient_ID, patient_ids)))
  colData(spe)$biology <- paste0(colData(spe)$Category, "_", colData(spe)$Segment)
  spe
}

# ==== Differential expression ==================================================

# DGEList from a SpatialExperiment. spe2dge keeps the TMM normalisation factors
# computed by geomxNorm, so they are not recalculated.
spe_to_dge <- function(spe) {
  dge <- spe2dge(spe)
  dge$samples <- dge$samples[, !grepl("\\.1$", colnames(dge$samples))]  # drop duplicated columns
  dge
}

# Strip the factor name from design columns and make them syntactic
# ("Endometriosis CLE" -> "Endometriosis_CLE").
tidy_design <- function(design, prefix) {
  colnames(design) <- gsub(prefix, "", colnames(design))
  colnames(design) <- gsub(" ", "_", colnames(design))
  colnames(design) <- gsub("-", "_", colnames(design))
  design
}

# limma-voom with patient blocking, as described in Methods:
# filterByExpr -> estimateDisp (BCV plot, diagnostic only) -> voom ->
# duplicateCorrelation (run twice) -> lmFit -> contrasts -> robust eBayes.
# Extra arguments go to filterByExpr.
fit_dge <- function(dge, design, contrasts, block, ...) {
  dge <- dge[filterByExpr(dge, design, ...), ]
  dge <- estimateDisp(dge, design = design, robust = TRUE)
  plotBCV(dge)

  vobj_tmp <- voom(dge, design, plot = FALSE)
  dupcor <- duplicateCorrelation(vobj_tmp, design, block = block)
  vobj <- voom(dge, design, plot = FALSE, block = block, correlation = dupcor$consensus)
  dupcor <- duplicateCorrelation(vobj, design, block = block)

  fit <- lmFit(vobj, design, block = block, correlation = dupcor$consensus)
  efit <- eBayes(contrasts.fit(fit, contrasts = contrasts), robust = TRUE)
  list(dge = dge, vobj = vobj, efit = efit)
}

# Full topTable for one contrast, ordered by p-value.
top_table <- function(efit, coef) topTable(efit, coef = coef, sort.by = "P", n = Inf)

# Genes passing FDR and |logFC| thresholds that are also in `genes`.
sig_genes_in <- function(tt, genes, fdr = 0.05, fc = 1.5) {
  rownames(tt)[tt$adj.P.Val < fdr & abs(tt$logFC) > fc & rownames(tt) %in% genes]
}

# Volcano plot. `label_genes` are written on the plot; `left`/`right` add
# "Upregulated in ..." captions at (-/+ caption_x, caption_y). Vertical lines are
# drawn at +/- fc_dashed and +/- fc_dotted (NULL to omit).
# Text sizes are in points as printed: `print_scale` is the printed width of the
# exported plot over its exported width (e.g. 255 pt on the page / 720 pt exported),
# so all volcano plots print with the same axis, caption and gene-label sizes.
plot_volcano <- function(tt, label_genes, col_low, col_high, xlim, ylim,
                         fc_dashed = 1.5, fc_dotted = 1.5, fdr = 0.05,
                         left = NULL, right = NULL, caption_x = 4.5, caption_y = NULL,
                         print_scale = 0.5, label_pt = 5, axis_pt = 5.5, title_pt = 6.5, caption_pt = 6,
                         box_padding = 0.35, max_overlaps = Inf, repel_iter = 2e5) {
  to_mm <- function(pt) pt / print_scale / .pt   # geom text sizes are in mm
  text_size <- to_mm(label_pt); caption_size <- to_mm(caption_pt)
  df <- tt %>%
    mutate(gene = rownames(tt),
           negLog10FDR = -log10(adj.P.Val),
           label = ifelse(gene %in% label_genes, gene, ""))

  p <- ggplot(df, aes(x = logFC, y = negLog10FDR)) +
    geom_point(aes(color = logFC, alpha = negLog10FDR)) +
    scale_color_gradient2(low = col_low, mid = "white", high = col_high, midpoint = 0,
                          name = expression(log[2]*" FC")) +
    scale_alpha_continuous(range = c(0.75, 1), guide = "none") +
    # black ring around the labelled genes' points (same printed line width in every figure)
    geom_point(data = function(d) d[d$label != "", ], shape = 21, fill = NA, colour = "black",
               stroke = 0.15 / print_scale)
  if (!is.null(fc_dashed)) p <- p + geom_vline(xintercept = c(-fc_dashed, fc_dashed), linetype = "dashed", color = "black")
  if (!is.null(fc_dotted)) p <- p + geom_vline(xintercept = c(-fc_dotted, fc_dotted), linetype = "dotted", color = "black")
  p <- p +
    geom_hline(yintercept = -log10(fdr), linetype = "dashed", color = "black") +
    xlab(expression(log[2]*" FC")) +
    ylab(expression(-log[10]*" FDR")) +
    xlim(xlim) +
    ylim(ylim) +
    theme_classic(base_size = title_pt / print_scale) +
    theme(axis.text = element_text(size = axis_pt / print_scale, colour = "black"),
          axis.title = element_text(size = title_pt / print_scale))
  if (!is.null(right)) p <- p + annotate("text", x = caption_x, y = caption_y, label = paste0("Upregulated\nin ", right),
                                         vjust = -0.2, hjust = 0.5, size = caption_size)
  if (!is.null(left)) p <- p + annotate("text", x = -caption_x, y = caption_y, label = paste0("Upregulated\nin ", left),
                                        vjust = -0.2, hjust = 0.5, size = caption_size)
  # Gene labels last, on top of the points and the dashed lines: a white halo keeps them
  # legible; every moved label gets a grey leader line; they avoid only the labelled and the
  # significant points (the faint cloud below the FDR line is free space), which lets the
  # repulsion settle without overlaps. The fixed seed and a fixed number of iterations (no time
  # limit, which made the placement depend on the speed of the machine) give the same labels every run
  p + geom_text_repel(data = function(d) d[d$label != "" | d$adj.P.Val < fdr, ], aes(label = label),
                      size = text_size, max.overlaps = max_overlaps,
                      bg.color = "white", bg.r = 0.12, box.padding = box_padding, point.padding = 0.15,
                      min.segment.length = 0, segment.color = "grey35", segment.size = 0.3,
                      force = 3, force_pull = 0.5, max.time = Inf, max.iter = repel_iter, seed = 42) +
    theme(legend.position = "none")
}

# ==== Gene-set enrichment ======================================================

# logFC of one contrast, named by Entrez ID and sorted decreasingly (GSEA input).
ranked_logfc <- function(efit, coef = NULL) {
  topTable(efit, coef = coef, number = Inf) %>%
    dplyr::select(logFC, GeneID) %>%
    filter(!is.na(GeneID)) %>%
    arrange(desc(logFC)) %>%
    { setNames(.$logFC, .$GeneID) }
}

# MSigDB gene sets (Hallmarks by default) as a TERM2GENE table
msigdb_sets <- function(collection = "H") {
  msigdbr(species = "Homo sapiens", collection = collection) %>%
    dplyr::select(gs_name, db_ncbi_gene)
}

# GO biological-process sets (with descendant terms, as gseGO uses) for the given
# Entrez IDs, as a TERM2GENE table
go_bp_sets <- function(genes) {
  m <- AnnotationDbi::select(org.Hs.eg.db, keys = genes, columns = c("GOALL", "ONTOLOGYALL"), keytype = "ENTREZID")
  unique(m[which(m$ONTOLOGYALL == "BP"), c("GOALL", "ENTREZID")])
}

# GSEA keeping gene sets with 10-500 genes in the ranked list and BH-adjusted p <= 0.05,
# ordered by adjusted p and |NES|.
# Since DOSE 4.6 (enrichit backend, clusterProfiler 4.20) the size limits apply to the
# whole annotation and pvalueCutoff to the raw p-value; restricting each set to the
# genes in the list and filtering on p.adjust keeps the standard GSEA definition.
# p-values come from permutations: a fixed seed per call makes results reproducible.
gsea_sets <- function(gene_list, term2gene, term2name = NULL) {
  term2gene <- term2gene[term2gene[[2]] %in% names(gene_list), ]
  set.seed(123)
  res <- GSEA(geneList = gene_list, TERM2GENE = term2gene, TERM2NAME = term2name,
              minGSSize = 10, maxGSSize = 500, pvalueCutoff = 0.05, pAdjustMethod = "BH", verbose = FALSE)
  res@result <- res@result[which(res@result$p.adjust <= 0.05), ]
  # Order as fgsea-based DOSE did: adjusted p, then |NES| (many sets tie at the p-value floor;
  # dot plots show the first rows)
  res@result <- res@result[order(res@result$p.adjust, -abs(res@result$NES)), ]
  res
}

gsea_go <- function(gene_list) {
  sets <- go_bp_sets(names(gene_list))
  term_names <- data.frame(term = unique(sets$GOALL), name = AnnotationDbi::Term(unique(sets$GOALL)))
  res <- gsea_sets(gene_list, sets, term_names)
  res@result$Description <- str_to_title(res@result$Description)
  res
}

gsea_hallmark <- function(gene_list, sets = msigdb_sets()) {
  res <- gsea_sets(gene_list, sets)
  res@result$Description <- sub("^HALLMARK_", "", res@result$Description)
  res
}

# NES dot plot with "Upregulated in ..." captions above the panel. With
# captions_at_zero = TRUE both captions start at the dashed NES = 0 line and run
# outwards (narrow panels, where centred captions would collide).
plot_gsea <- function(gsea, show = 30, label_format = 50, right = NULL, left = NULL,
                      x_right = 2, x_left = -2, legend_text = 5, caption_size = 3, captions_at_zero = FALSE) {
  if (captions_at_zero) { x_right <- 0; x_left <- 0 }
  hjust_right <- if (captions_at_zero) -0.05 else 0.5
  hjust_left  <- if (captions_at_zero) 1.05 else 0.5
  p <- dotplot(gsea, x = "NES", showCategory = show, label_format = label_format) +
    geom_vline(xintercept = 0, color = "darkgray", linetype = "dashed") +
    ggtitle(NULL) + coord_cartesian(clip = "off") + xlab("NES")
  if (!is.null(right)) p <- p + annotate("text", x = x_right, y = Inf, label = paste0("Upregulated\nin ", right),
                                         vjust = -0.2, hjust = hjust_right, size = caption_size)
  if (!is.null(left)) p <- p + annotate("text", x = x_left, y = Inf, label = paste0("Upregulated\nin ", left),
                                        vjust = -0.2, hjust = hjust_left, size = caption_size)
  p + theme_classic() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.75),
          plot.margin = margin(t = 30, r = 5, b = 5, l = 5),
          legend.position = "bottom", legend.box = "vertical",
          legend.text = element_text(size = legend_text), legend.title = element_text(size = 6))
}

# Styling for narrow, tall GSEA panels: legends centred under the plot, fixed NES
# ticks/limits, tight line spacing for wrapped term names (Fig 2e-f, 3c-d, 3g-h).
gsea_theme <- function(key_width, margin_r, nes_breaks = c(-2, 0, 2), nes_limits = NULL) {
  list(scale_x_continuous(breaks = nes_breaks, limits = nes_limits),
       theme(legend.text = element_text(size = 7), legend.title = element_text(size = 8), legend.location = "plot",
             legend.key.width = unit(key_width, "cm"), plot.margin = margin(t = 30, r = margin_r, b = 5, l = 5),
             axis.text.y = element_text(lineheight = 0.8)))
}

# ==== Deconvolution ============================================================

# Cell-type proportions (cell types x AOIs) in long format with the AOI category
# and patient: source data of the deconvolution panels
prop_source <- function(prop, meta) {
  prop %>%
    as.data.frame() %>%
    rownames_to_column("CellType") %>%
    gather(AOI, Proportion, -CellType) %>%
    mutate(Category = meta[AOI, "Category"], Patient = as.character(meta[AOI, "Patient"])) %>%
    dplyr::select(AOI, Category, Patient, CellType, Proportion)
}

# Stacked bar plot of cell-type proportions per AOI (Supp Fig 7a / 9a).
plot_prop_bars <- function(prop, palette, legend_title = "Cell types") {
  bars <- prop %>%
    as.data.frame() %>%
    rownames_to_column("CellTypes") %>%
    gather(samples, prop, -CellTypes)
  ggplot(bars, aes(samples, prop, fill = CellTypes)) +
    geom_bar(stat = "identity", position = "stack", color = "black", width = .7) +
    coord_flip() +
    scale_fill_manual(name = legend_title, values = palette, breaks = names(palette)) +
    theme_classic() +
    ylab("Proportion") + xlab("") +
    theme(legend.position = "right",
          axis.line.y = element_blank(), axis.ticks.y = element_blank(),
          axis.text.y = element_blank())
}

# Heatmap of cell-type proportions annotated by Category (Supp Fig 7b / 9b).
plot_prop_heatmap <- function(prop, category) {
  annotation_col <- data.frame(Category = order_category(category))   # legend in the category order
  rownames(annotation_col) <- colnames(prop)
  pheatmap(prop,
           annotation_col = annotation_col, annotation_colors = list(Category = Category),
           color = colorRampPalette(c("white", "#6F93B8", navy))(100), border_color = "black",
           show_colnames = FALSE, name = "%")
}

# Square PC1/PC2 limits: the same span on both axes (centred on the data, plus a
# margin for the floret petals), so the floret and PCA plots are equal squares.
square_limits <- function(pc, pad = 0.07) {
  span <- max(diff(range(pc[, 1])), diff(range(pc[, 2]))) * (1 + 2 * pad)
  lapply(list(x = pc[, 1], y = pc[, 2]), function(v) mean(range(v)) + c(-1, 1) * span / 2)
}

# Floret plot: each AOI at its PCA position, with one wedge per cell type whose
# radius is proportional to the estimated proportion (Fig 6c / 6f, left).
plot_florets <- function(prop, pc, palette, petal = 0.1) {
  pc_df <- as.data.frame(pc) %>% tibble::rownames_to_column("sample")
  lims <- square_limits(pc)
  prop_df <- prop %>%
    as.data.frame() %>%
    rownames_to_column("celltype") %>%
    gather(sample, prop, -celltype)

  floret_df <- prop_df %>%
    left_join(pc_df, by = "sample") %>%
    group_by(sample) %>%
    mutate(idx    = row_number() - 1,
           ntypes = n(),
           width  = 2 * pi / ntypes,
           start  = idx * width,
           end    = (idx + 1) * width,
           s      = petal * max(diff(range(pc_df$PC1)), diff(range(pc_df$PC2))),  # petal radius as a fraction of the PC range
           r      = prop * s) %>%
    ungroup()

  ggplot(floret_df) +
    geom_point(aes(PC1, PC2), color = "black", size = 1) +
    geom_arc_bar(aes(x0 = PC1, y0 = PC2, r0 = 0, r = r, start = start, end = end, fill = celltype),
                 color = "black", alpha = 0.8, expand = FALSE) +
    coord_equal(xlim = lims$x, ylim = lims$y) +
    scale_fill_manual(name = "Cell types", values = palette, breaks = names(palette)) +
    theme_classic(base_size = 11) +
    theme(axis.ticks = element_blank(), legend.position = "right",
          legend.title.position = "top", legend.title = element_text(hjust = 0)) +
    guides(fill = guide_legend(ncol = 1))
}

# PCA of the AOIs coloured by Category (Fig 6c / 6f, right); same equal-axis
# geometry and legend style as the floret plot it sits next to.
plot_pca_category <- function(pc, category) {
  pc_df <- merge(pc, data.frame(Category = order_category(category), row.names = rownames(pc)), by = "row.names")
  lims <- square_limits(pc)
  ggplot(pc_df, aes(x = PC1, y = PC2, fill = Category)) +
    geom_point(size = 3, shape = 21, color = "black") +
    coord_equal(xlim = lims$x, ylim = lims$y) +
    theme_classic(base_size = 11) +
    scale_fill_manual(values = Category) +
    theme(axis.ticks = element_blank(), legend.position = "right",
          legend.title.position = "top", legend.title = element_text(hjust = 0)) +
    guides(fill = guide_legend(ncol = 1))
}

# Fix the plot-area size (all panels) of a ggplot and, optionally, the width of its right legend
# column; returns the gtable. Plots built this way line up whatever their axis or legend labels.
fixed_panels <- function(p, w, h, legend_w = NULL) {
  g <- ggplotGrob(p)
  panel <- g$layout[grepl("^panel", g$layout$name), ]
  g$widths[unique(panel$l)] <- unit(w, "in"); g$heights[unique(panel$t)] <- unit(h, "in")
  if (!is.null(legend_w)) g$widths[g$layout$l[g$layout$name == "guide-box-right"]] <- unit(legend_w, "in")
  g
}
grob_size <- function(g) c(w = sum(convertWidth(g$widths, "in", TRUE)), h = sum(convertHeight(g$heights, "in", TRUE)))

# Fig 6c / 6f: florets and PCA by Category side by side, each with its own legend on its right.
# Same square plot area and legend column in both, so 6c and 6f line up column by column.
plot_pca_pair <- function(prop, pc, palette, category, petal = 0.07, panel = 2.7, legend_w = 2) {
  style <- list(guides(fill = guide_legend(ncol = 1)),
                theme(legend.position = "right", legend.justification = c(0, 0.5), legend.title.position = "top",
                      legend.title = element_text(size = 10, hjust = 0), legend.text = element_text(size = 9),
                      legend.key.size = unit(0.4, "cm")))
  cbind(fixed_panels(plot_florets(prop, pc, palette, petal = petal) + style, panel, panel, legend_w),
        fixed_panels(plot_pca_category(pc, category) + style, panel, panel, legend_w), size = "max")
}

# Boxplots of cell-type proportions (Fig 6d / 6g), one facet per Category, cell types named under each box.
# Points and box lines as Figure 1d (black dot per ROI, no outlier markers), sized for the 12.75 in
# export printed 536 pt wide. The box width scales with the number of cell types, so 6d (5) and
# 6g (3) have boxes of the same printed width.
plot_prop_boxplot <- function(prop, meta, palette, legend = TRUE) {
  df <- prop %>%
    as.data.frame() %>%
    rownames_to_column(var = "CellTypes") %>%
    gather(key = "samples_id", value = "prop", -CellTypes) %>%
    left_join(rownames_to_column(meta, var = "samples_id"), by = "samples_id") %>%
    mutate(Category = order_category(Category), CellTypes = in_order(CellTypes, palette))
  box_width <- 0.75 * nrow(prop) / 5
  ggplot(df, aes(CellTypes, prop, fill = CellTypes)) +
    geom_boxplot(width = box_width, linewidth = 0.45, outlier.shape = NA) +
    geom_point(size = 0.9) +
    # every facet has its own y axis line and ticks; the numbers only on the first one
    facet_wrap(~ Category, nrow = 1, labeller = as_labeller(Category_short), axes = "all_y", axis.labels = "margins") +
    theme_classic() +
    xlab("") +
    ylab("Proportion") +
    scale_fill_manual(name = "Cell types", values = palette) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5, size = 8, colour = "black"),
          strip.background = element_blank(), strip.text = element_text(face = "bold", size = 10),
          panel.spacing.x = unit(2, "mm"),
          legend.position = if (legend) "right" else "none", legend.title = element_text(size = 10),
          legend.text = element_text(size = 9), legend.key.size = unit(0.35, "cm"),
          legend.margin = margin(0, 0, 0, 0)) +
    guides(fill = guide_legend(ncol = 1))
}

# Differential proportions between all pairs of categories: arcsine-square-root
# transformed proportions, limma with patient blocking (duplicateCorrelation).
test_proportions <- function(prop, category, patient,
                             levels = c("Atypical endometriosis", "Endometriosis CLE", "Clear cell carcinoma",
                                        "Endometrioid carcinoma", "Simple endometriosis")) {
  prop_list <- convertDataToList(x = prop, data.type = "proportions", transform = "asin")
  # Contrasts are all pairs in `levels` order (first minus second): the order of the published
  # analysis, so the pairs and the signs of the log2FC are the same
  stopifnot(all(category %in% levels))
  grp <- factor(gsub("[- ]", "_", category), levels = gsub("[- ]", "_", intersect(levels, category)))
  pt  <- factor(patient)

  design <- model.matrix(~ 0 + grp)
  colnames(design) <- gsub("^grp", "", colnames(design))

  dupcor <- duplicateCorrelation(prop_list$TransformedProps, design, block = pt)
  fit <- lmFit(prop_list$TransformedProps, design, block = pt, correlation = dupcor$consensus)

  results <- lapply(combn(levels(grp), 2, simplify = FALSE), function(pp) {
    contrast_name <- paste(pp, collapse = "-")
    fit2 <- eBayes(contrasts.fit(fit, makeContrasts(contrasts = contrast_name, levels = design)))
    topTable(fit2, number = Inf, adjust.method = "fdr") %>%
      tibble::rownames_to_column("CellType") %>%
      mutate(Contrast = contrast_name)
  })

  results <- do.call(rbind, results)
  results$log10FDR <- -log(results$adj.P.Val, 10)
  results <- results %>%
    mutate(Contrast = gsub("_", " ", Contrast),
           Contrast = gsub("-", " - ", Contrast),
           Contrast = factor(Contrast, levels = unique(Contrast)))   # rows of Fig 6e / 6h in the contrast order
  rownames(results) <- NULL
  results
}

# Bubble plot of the pairwise tests (Fig 6e / 6h). Bubbles with FDR below
# `border_fdr` get a black border. Legend order fixed: log2FC, then -log10(FDR).
plot_prop_bubbles <- function(results, palette, border_fdr = 0.1) {
  results$CellType <- in_order(results$CellType, palette)   # cell types in the palette order, as in the boxplots
  ggplot(results, aes(x = Contrast, y = CellType, size = log10FDR, fill = logFC)) +
    geom_point(shape = 21, color = ifelse(results$adj.P.Val < border_fdr, "black", "NA")) +
    theme_classic() +
    theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
          legend.direction = "vertical", legend.box = "vertical",
          legend.title = element_text(size = 9), legend.text = element_text(size = 8),
          legend.key.size = unit(0.35, "cm"), legend.spacing.y = unit(0.15, "cm")) +
    xlab("") + ylab("") +
    labs(size = "-log10(FDR)") +
    coord_flip() +
    scale_fill_gradient2(name = "log2FC", low = div_low, mid = div_mid, high = div_high, midpoint = 0) +
    guides(fill = guide_colourbar(order = 1, barheight = unit(1.5, "cm")), size = guide_legend(order = 2))
}
