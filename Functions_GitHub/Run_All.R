# Knit all notebooks in order (each in a fresh environment) and record the
# package versions used. Run from this folder:
#   Rscript Run_All.R            # all notebooks
#   Rscript Run_All.R 10 12      # only the notebooks whose number is given

notebooks <- sort(list.files(pattern = "^[0-9]{2}_.*\\.Rmd$"))
args <- commandArgs(trailingOnly = TRUE)
if (length(args) > 0) notebooks <- notebooks[substr(notebooks, 1, 2) %in% sprintf("%02d", as.integer(args))]

dir.create("../OUTPUT/reports", showWarnings = FALSE, recursive = TRUE)
for (nb in notebooks) {
  message("Knitting ", nb)
  rmarkdown::render(nb, output_dir = "../OUTPUT/reports", envir = new.env(), quiet = TRUE)
}

# Package versions only for a full run (a partial run loads fewer packages)
if (length(args) == 0) {
  writeLines(capture.output(sessionInfo()), "../OUTPUT/reports/sessionInfo.txt")
  source("Software_Versions.R")   # OUTPUT/TABLES/Software_Versions.xlsx (supplementary material)
}
