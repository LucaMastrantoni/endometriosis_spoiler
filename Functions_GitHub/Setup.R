# Shared setup, sourced by the first chunk of every notebook.
# Notebooks are knitted from this folder; inputs and results live one level up:
#   ../DATA_INPUT              raw DCC/PKC files, annotation and other inputs (read only)
#   ../OUTPUT/rds              intermediate objects passed between notebooks
#   ../OUTPUT/FIGURES          figure panels, in Main/FigureN/ and Supplementary/FigureSN/
#   ../OUTPUT/Excel Files      source data, one workbook per panel (same subfolders as FIGURES)
#   ../OUTPUT/TABLES           result tables (.xlsx)
#   ../OUTPUT/RData            workspace of each notebook (objects and plots)
#   ../OUTPUT/reports          knitted notebooks

# ---- Packages -----------------------------------------------------------------
# The attach order is kept from the original analysis because it decides which
# package wins when two of them export a function with the same name.
suppressPackageStartupMessages({
  library(NanoStringNCTools)
  library(GeomxTools)
  library(GeoMxWorkflows)
  library(scales)
  library(pheatmap)
  library(openxlsx)
  library(ggplot2)
  library(ggpubr)
  library(ggrepel)
  library(dplyr)
  library(ggforce)
  library(SingleCellExperiment)
  library(SpatialExperiment)
  library(ggalluvial)
  library(standR)
  library(ggnewscale)
  library(tidyverse)
  library(edgeR)
  library(limma)
  library(readxl)
  library(statmod)
  library(SpatialDecon)
  library(clusterProfiler)
  library(enrichplot)
  library(tibble)
  library(patchwork)
  library(cowplot)
  library(ggsci)
  library(gridExtra)
  library(scater)
  library(reshape2)
  library(Seurat)
  library(SeuratObject)
  library(circlize)
  library(ComplexHeatmap)
  library(grid)
  library(org.Hs.eg.db)
  library(ggtangle)
  library(ggbeeswarm)
  library(msigdbr)
  library(nnet)
  library(speckle)
  library(SeuratExtend)
})

# ---- Paths --------------------------------------------------------------------
path_input   <- "../DATA_INPUT"
path_output  <- "../OUTPUT"
path_rds     <- file.path(path_output, "rds")
path_figures <- file.path(path_output, "FIGURES")
path_source  <- file.path(path_output, "Excel Files")
path_tables  <- file.path(path_output, "TABLES")
path_rdata   <- file.path(path_output, "RData")

for (d in c(path_rds, path_figures, path_source, path_tables, path_rdata)) {
  dir.create(d, showWarnings = FALSE, recursive = TRUE)
}

# ---- Shared colours, functions and gene lists ---------------------------------
source("Colors.R")
source("Helpers.R")
source("Gene_Lists.R")
