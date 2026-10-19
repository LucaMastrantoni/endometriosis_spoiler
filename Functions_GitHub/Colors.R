# Colour palettes shared by the notebooks. Sourced by Setup.R.
# One muted family built around the ECLE ochre (#C99A4E); every palette is listed in the order the
# categories are shown (SE, ECLE, AE, CCC, EC), and the expression and significance gradients share the
# navy-white-brick scale of Figure 6e.

# ---- Gradients -----------------------------------------------------------------
navy  <- "#003C67"
brick <- "#A73030"
div_low <- navy; div_mid <- "white"; div_high <- brick   # log2 FC, correlation, scaled expression

# Diverging scale (heatmaps of scaled expression)
color <- colorRampPalette(c(div_low, div_mid, div_high))(100)
# Sequential scales: warm (pseudotime, detection rate) and cool (entropy, deconvolution heatmaps)
seq_warm <- c("#F6EDD9", "#C99A4E", brick, "#3B1E1A")
seq_cool <- c("#EEF2F6", "#87AFD4", "#4C7DAF", navy)
# n ordered steps of the warm scale (clustering resolutions, Supplementary Figure 4a-b)
warm_steps <- function(n) colorRampPalette(c("#EBD5A8", "#D98C5F", brick))(n)
# GSEA dot plots (enrichplot): adjusted p from terracotta (low) to steel blue (high); lighter than brick-navy,
# whose dark mid-tones made the gradient hard to read
options(enrichplot.colours = c("#B85A4E", "#4C7DAF"))

# ---- Categories ----------------------------------------------------------------
Category <- c("Simple endometriosis"   = "#4F8A5B",
              "Endometriosis CLE"      = "#C99A4E",
              "Atypical endometriosis" = "#4C7DAF",
              "Clear cell carcinoma"   = "#8A8A8A",
              "Endometrioid carcinoma" = "#B85A4E")

# Short labels, in the same order
Category_short <- c("Simple endometriosis" = "SE", "Endometriosis CLE" = "ECLE", "Atypical endometriosis" = "AE",
                    "Clear cell carcinoma" = "CCC", "Endometrioid carcinoma" = "EC")
Category_abbr <- setNames(Category, Category_short)   # colours by short label (SE, ECLE, ...)

Category_Group <-
  c("Simple endometriosis - Epithelial"            = "#4F8A5B",
    "Endometriosis CLE - Epithelial"               = "#C99A4E",
    "Atypical endometriosis - Epithelial"          = "#4C7DAF",
    "Atypical endometriosis - Atypical Epithelial" = "#87AFD4",
    "Clear cell carcinoma - Epithelial"            = "#8A8A8A",
    "Clear cell carcinoma - Cancer"                = "#4A4744",
    "Endometrioid carcinoma - Epithelial"          = "#B85A4E",
    "Endometrioid carcinoma - Cancer"              = "#8A3A31")

Group <- c("Epithelial"          = "#8DB39B",
           "Atypical Epithelial" = "#87AFD4",
           "Cancer"              = "#9E4A42",
           "Stroma"              = "#9C7BA5")

Segment <- c("CD3"   = "#C8553D",
             "CD68"  = "#E0B33A",
             "PanCK" = "#2E9C83")

# Light tints of the same family, one per patient
Patient <- c(
  "Pt_01" = "#A8C1DC",  # light steel blue
  "Pt_02" = "#EDB99A",  # light terracotta
  "Pt_03" = "#E7C3CF",  # dusty rose
  "Pt_04" = "#A9C6A0",  # sage
  "Pt_05" = "#C3B1CC",  # light plum
  "Pt_06" = "#DDA59D",  # light brick
  "Pt_07" = "#E4C990",  # light ochre
  "Pt_08" = "#B9A9B8",  # mauve grey
  "Pt_09" = "#9FB4C7",  # grey blue
  "Pt_10" = "#F0D2C4",  # pale peach
  "Pt_11" = "#9ECFC2",  # light teal
  "Pt_12" = "#D8CFA0",  # khaki
  "Pt_13" = "#D9DDE4",  # pale grey blue
  "Pt_14" = "#C9C9C9"   # light grey
)

# Alluvial plot (Figure 1b): patients, categories, segments and groups
Alluvial <- c(Patient, Category, Segment, Group)

# Clusters and categories (Supplementary Figure 4)
Cluster <- c(
  "0" = "#DDA59D",
  "1" = "#A8C1DC",
  "2" = "#A9C6A0",
  "3" = "#C3B1CC",
  "4" = "#E4C990",
  Category
)

# Qualitative set for unordered groups without a palette of their own (scans, K = 3/5 clusters)
Muted <- c("#4C7DAF", "#B85A4E", "#4F8A5B", "#C99A4E", "#9C7BA5", "#2E9C83", "#8A8A8A", "#D98C5F")

# Q3 counts and negative-probe background (Supplementary Figure 2)
QC_stat <- c("Q3" = "#D9A08F", "NegProbe" = "#87AFD4")

# Deconvolution cell types
Cell_Types <- c("T Cells (CD4)" = "#87AFD4",
                "T Cells (CD8)" = "#B85A4E",
                "T Reg"         = "#4A4744")

Macro <- c("LYVE1"       = "#E0B33A",
           "Peritoneal"  = "#87AFD4",
           "APOE"        = "#4A4744",
           "Infiltrated" = "#8A3A31",
           "Activated"   = "#8DB39B")

# GO network (Figure 7d): term nodes in the ECLE colour
GO_term_node <- Category[["Endometriosis CLE"]]

# ---- Order ---------------------------------------------------------------------
# Factor in the display order of a palette (values not in the palette keep their order, after it)
in_order <- function(x, palette) {
  x <- as.character(x)
  factor(x, levels = c(intersect(names(palette), x), setdiff(unique(x), names(palette))))
}
order_category <- function(x) in_order(x, Category)
