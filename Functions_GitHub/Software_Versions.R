# Table of the software used, with the installed versions, for the supplementary
# material: OUTPUT/TABLES/Software_Versions.xlsx. Written by Run_All.R after a
# full run (same R library as the run); can also be run on its own from this folder.

purpose <- c(
  # GeoMx data, QC and normalisation
  NanoStringNCTools = "GeoMx data structures",
  GeomxTools        = "DCC/PKC import, segment and probe QC, limit of quantification",
  GeoMxWorkflows    = "GeoMx workflow utilities",
  standR            = "SpatialExperiment conversion, TMM and RUV4 normalisation, RLE and QC plots",
  SpatialExperiment = "Data container",
  SingleCellExperiment = "Data container",
  S4Vectors         = "Data container",
  edgeR             = "TMM normalisation, filtering",
  limma             = "Differential expression (voom, linear models, duplicate correlation)",
  statmod           = "Mixed-model fitting for limma",
  scater            = "PCA",
  nnet              = "Multinomial regression of category on principal components",
  # Single-cell style analysis
  Seurat            = "UMAP, clustering, module scores",
  SeuratObject      = "Seurat data structures",
  SeuratExtend      = "Interface to Palantir (diffusion map, pseudotime, fate probabilities, MAGIC) and trajectory plots",
  clustree          = "Clustering trees across resolutions",
  entropy           = "Normalised entropy of category per cluster",
  # Deconvolution
  SpatialDecon      = "Cell-type deconvolution of CD68+ and CD3+ AOIs",
  SeuratDisk        = "Conversion of the macrophage reference (profile matrix prepared once; not re-run)",
  # Enrichment
  clusterProfiler   = "Gene set enrichment analysis and GO over-representation",
  DOSE              = "Enrichment engine used by clusterProfiler",
  enrichplot        = "Enrichment dot plots and gene-concept networks",
  ggtangle          = "Gene-concept network layout",
  msigdbr           = "MSigDB gene sets (Hallmark, C6)",
  org.Hs.eg.db      = "Gene identifiers and GO annotation",
  GO.db             = "GO term names",
  AnnotationDbi     = "Annotation queries",
  # Figures and tables
  ggplot2 = "Plots", ggpubr = "Bar plots", ggrepel = "Gene labels", ggforce = "Floret plots",
  ggalluvial = "Alluvial plots", ggnewscale = "Multiple fill scales", ggsci = "Colour palettes",
  ggbeeswarm = "Beeswarm points", patchwork = "Panel layout", cowplot = "Panel layout",
  ComplexHeatmap = "Heatmaps", circlize = "Heatmap colour scales", pheatmap = "Heatmaps",
  scales = "Axis scales", svglite = "SVG export", png = "SVG post-processing",
  base64enc = "SVG post-processing",
  dplyr = "Data handling", tidyverse = "Data handling", tibble = "Data handling",
  reshape2 = "Data handling",
  readxl = "Excel import", openxlsx = "Excel export",
  rmarkdown = "Reports", knitr = "Reports"
)

source_of <- function(pkg) {
  d <- utils::packageDescription(pkg)
  if (!is.null(d$biocViews) || identical(d$Repository, "Bioconductor")) "Bioconductor"
  else if (identical(d$Repository, "CRAN")) "CRAN"
  else if (!is.null(d$RemoteType) && d$RemoteType == "github") paste0("GitHub (", d$RemoteUsername, "/", d$RemoteRepo, ")")
  else if (!is.null(d$Repository)) d$Repository
  else "other"
}

packages <- data.frame(Software = names(purpose),
                       Version = vapply(names(purpose), function(p) utils::packageDescription(p)$Version, ""),
                       Source = vapply(names(purpose), source_of, ""),
                       Purpose = unname(purpose))

# Python tools used through SeuratExtend (its own conda environment)
python <- tryCatch({
  py <- reticulate::conda_python("seuratextend")
  pip <- system2(py, c("-m", "pip", "list", "--format=freeze"), stdout = TRUE)
  ver <- function(name) sub(".*==", "", grep(paste0("^", name, "=="), pip, value = TRUE, ignore.case = TRUE))
  data.frame(Software = c("Python", "palantir", "scanpy", "anndata"),
             Version = c(sub("Python ", "", system2(py, "--version", stdout = TRUE)), ver("palantir"), ver("scanpy"), ver("anndata")),
             Source = c("python.org", "PyPI", "PyPI", "PyPI"),
             Purpose = c("Runtime for Palantir (via SeuratExtend)", "Diffusion maps, pseudotime, fate probabilities, MAGIC imputation",
                         "AnnData handling for Palantir", "AnnData handling for Palantir"))
}, error = function(e) NULL)

software <- rbind(
  data.frame(Software = "R", Version = paste(R.version$major, R.version$minor, sep = "."), Source = "r-project.org",
             Purpose = "Statistical computing"),
  data.frame(Software = "Bioconductor", Version = as.character(BiocManager::version()), Source = "bioconductor.org",
             Purpose = "Release of the Bioconductor packages"),
  packages[order(packages$Source != "Bioconductor", tolower(packages$Software)), ],
  python)

dir.create("../OUTPUT/TABLES", showWarnings = FALSE, recursive = TRUE)
openxlsx::write.xlsx(list(Software_Versions = software), "../OUTPUT/TABLES/Software_Versions.xlsx",
                     rowNames = FALSE, firstRow = TRUE, colWidths = "auto")
