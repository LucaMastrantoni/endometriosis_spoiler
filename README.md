# Spatially Resolved Epithelial–Immune Heterogeneity Identifies an Endometriosis Subtype with Molecular Features of Endometriosis-Associated Ovarian Cancer 

V. Iacobelli#, L. Mastrantoni#, S. Alivernini, G. Scaglione, A. Agostini, G. Mantini, A. Piermattei, F. Persiani, F. Camarda, R. Trozzi, 
F. Sillano, M.A. D’Agostino, G. Schett, C. Carbone, G. Scambia, A. Fagotti, C. Nero\*.

\# Equal contribution. \* Corresponding author.

## Contents

```
Functions_GitHub/   R Markdown notebooks 01-22 and R code
DATA_INPUT/         sample annotation, patient covariates, immunohistochemistry,
                    multiplex immunofluorescence counts, macrophage profile matrix
```

## Data

The raw GeoMx files are on GEO (GSE316381). Download the DCC files into
`DATA_INPUT/dccs/` and the PKC file (zip) into `DATA_INPUT/pkcs/`. All other
inputs are in `DATA_INPUT/`.

## Running

Requires R (analyses run with R 4.6.0) and the Bioconductor/CRAN packages
loaded in `Functions_GitHub/Setup.R`. `14_Trajectory` also needs
SeuratExtend, which sets up its own Python environment for Palantir.

From `Functions_GitHub/`:

```r
source("Run_All.R")   # all notebooks, in order
```

Notebooks 01-05 build the objects used by the others. Results are written to
`OUTPUT/`.

## Notebooks

| Notebook | Content | Output |
|---|---|---|
| 01_Preprocessing | GeoMx import, QC, LOQ, filtering | Supp. Fig. 2 |
| 02_SPE_Preparation | SpatialExperiment object | |
| 03_Batch_Correction | TMM, RUV4 | Supp. Fig. 3 |
| 04_Seurat_Preparation | Seurat objects, PCA, UMAP | |
| 05_Deconvolution_Preparation | As 03, for deconvolution | |
| 06_Cohort_Summary | AOI summary, immunohistochemistry | Fig. 1b-d, Supp. Tables 2 and 3B |
| 07_Segment_Markers | Segment markers | Fig. 1e |
| 08_PanCK_PCA | PCA, correlation | Fig. 2a-b, Supp. Table 4 |
| 09_PanCK_Clustering | Clustering resolutions | Supp. Fig. 4 |
| 10_DGE_PanCK_Endometriosis | CLE vs SE, CLE vs AE | Fig. 2c-f |
| 11_DGE_PanCK_Endometriosis_Sensitivity | Adjusted for menstrual phase, COC | Supp. Fig. 5 |
| 12_DGE_PanCK_Cancer | Carcinoma vs SE and vs CLE | Fig. 3 |
| 13_PanCK_Signatures | One-vs-all genes, module scores | Fig. 4 |
| 14_Trajectory | Palantir pseudotime and fates | Fig. 5 |
| 15_DGE_PanCK_Cancer_vs_Adjacent | Cancer vs adjacent epithelium | Supp. Fig. 6 |
| 16_DGE_CD68 | CD68+ CLE vs SE, CLE vs AE | Fig. 6a-b |
| 17_Deconvolution_CD68 | Macrophage subtypes | Fig. 6c-e, Supp. Fig. 7 |
| 18_DGE_CD3 | CD3+ CLE vs SE, CLE vs AE | Supp. Fig. 8 |
| 19_Deconvolution_CD3 | T-cell subtypes (safeTME) | Fig. 6f-h, Supp. Fig. 9 |
| 20_DGE_Bulk_CLE | All AOIs, CLE vs SE + AE | Fig. 7a-d |
| 21_Opal | Multiplex immunofluorescence | Fig. 8b, 8e |
| 22_Source_Data | All source data | `Source_Data.xlsx` |
