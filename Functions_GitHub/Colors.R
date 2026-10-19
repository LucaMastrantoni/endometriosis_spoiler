# Colour palettes shared by the notebooks. Sourced by Setup.R.

Segment <- c("CD3" = "#E64B35FF",
             "CD68" = "#F0AB00FF",
             "PanCK" = "#00A087FF")

Category <- c("Atypical endometriosis" = "#0073C2FF",
              "Cancer-like endometriosis" = "#EFC000FF",
              "Clear cell carcinoma" = "#868686FF",
              "Endometrioid carcinoma" = "#CD534CFF",
              "Simple endometriosis" = "#20854EFF")

Group <- c("Atypical Epithelial" = "#00A1D5FF",
           "Cancer" = "#B24745FF",
           "Epithelial" = "#79AF97FF",
           "Stroma" = "#DF8F44FF")

Patient <- c(
  "Pt_01" = "#AEC6CF",  # pastel blue
  "Pt_02" = "#FFB347",  # pastel orange
  "Pt_03" = "#FFD1DC",  # pastel pink
  "Pt_04" = "#77DD77",  # pastel green
  "Pt_05" = "#CBAACB",  # pastel lavender
  "Pt_06" = "#FF6961",  # pastel red
  "Pt_07" = "#FDFD96",  # pastel yellow
  "Pt_08" = "#B39EB5",  # pastel purple
  "Pt_09" = "#779ECB",  # pastel denim
  "Pt_10" = "#FFB7CE",  # soft pink
  "Pt_11" = "#B0E0E6",  # powder blue
  "Pt_12" = "#F49AC2",  # rose pink
  "Pt_13" = "#E6E6FA",  # lavender
  "Pt_14" = "#D6CADD"   # dusty mauve
)

Category_Group <-
  c("Atypical endometriosis - Epithelial" = "#0073C2FF",
    "Atypical endometriosis - Atypical Epithelial" = "#00A1D5FF",
    "Cancer-like endometriosis - Epithelial" = "#EFC000FF",
    "Clear cell carcinoma - Epithelial" = "#868686FF",
    "Clear cell carcinoma - Cancer" = "#3B3B3BFF",
    "Endometrioid carcinoma - Epithelial" = "#CD534CFF",
    "Endometrioid carcinoma - Cancer" = "#A73030FF",
    "Simple endometriosis - Epithelial" = "#20854EFF")

# Alluvial plot (Figure 1b): patients, categories, segments and groups
Alluvial <- c(Patient, Category, Segment, Group)

# Clusters and categories (Supplementary Figure 4)
Cluster <- c(
  "0" = "#FBB4AE",
  "1" = "#B3CDE3",
  "2" = "#CCEBC5",
  "3" = "#DECBE4",
  "4" = "#FED9A6",
  Category
)

# Diverging blue-white-red scale
color <- colorRampPalette(c("#2166ac", "#f7f7f7", "#b2182b"))(100)

# Deconvolution cell types
Cell_Types <- c(
  "T Cells (CD4)"        = "#00A1D5FF",
  "T Cells (CD8)"        = "#CD534CFF",
  "T Reg"                = "#3B3B3BFF"
)

Macro <- c("LYVE1" = "#F0AB00FF",
           "Peritoneal" = "#00A1D5FF",
           "APOE" = "#3B3B3BFF",
           "Infiltrated" = "#A73030FF",
           "Activated" = "#79AF97FF")
