# Gene lists shared by the notebooks. Sourced by Setup.R.
# Functional groups follow the endometrial epithelial populations of
# Marečková et al. (Supplementary Note 1).

epithelial_programs <- list(
  "Progenitor"             = c("SOX9", "CDH2", "AXIN2", "ALDH1A1"),
  "Glands - Proliferative" = c("SLC7A11", "DKK1", "PHLDA1", "KMO", "IHH", "EMID1"),
  "Glands - Secretory"     = c("HPRT1", "SUFU", "OPRK1", "CBR3", "S100P", "SCGB2A2", "ABCG1", "PAEP", "DPP4", "GPX3", "PTPRR", "FGF7", "FXYD2"),
  "Lumen - Proliferative"  = c("IL32", "WNT7A", "LGR5", "MMP7", "TNF"),
  "Lumen - Secretory"      = c("VTCN1", "CLDN22", "SULT1E1", "LEFTY1", "LGR5", "PTGS1", "IL6"),
  "Ciliated"               = c("CCNO", "CDC20B", "MUC12", "PIFO", "FOXJ1", "TP73", "C1orf194", "RSPH1"),
  "MUC5B"                  = c("MUC5B", "TFF3", "BPIFB1", "SAA1", "LCN2", "LTF"),
  "Steroid receptors"      = c("PGR", "AR", "ESR1")
)

# Module scores (Figure 4e, Figure 5e)
module_genes <- list(
  "Proliferative"     = c("SOX9", "SLC7A11", "DKK1", "PHLDA1", "KMO", "IHH", "EMID1", "IL32", "WNT7A", "LGR5", "MMP7", "TNF"),
  "Secretory"         = c("HPRT1", "SUFU", "OPRK1", "CBR3", "S100P", "SCGB2A2", "ABCG1", "PAEP", "DPP4", "GPX3", "PTPRR", "FGF7", "FXYD2",
                          "VTCN1", "CLDN22", "SULT1E1", "LEFTY1", "LGR5", "PTGS1", "IL6"),
  "Ciliated"          = c("CCNO", "CDC20B", "MUC12", "PIFO", "FOXJ1", "TP73", "C1orf194", "RSPH1"),
  "MUC5B"             = c("MUC5B", "TFF3", "BPIFB1", "SAA1", "LCN2", "LTF"),
  "Steroid receptors" = c("PGR", "AR", "ESR1")
)

# Genes that may be labelled on the PanCK volcano plots (only if significant)
volcano_genes_endometriosis <- c(
  "SLC7A11", "DKK1", "PHLDA1", "KMO", "IHH", "EMID1", "TP53TG3F", "PTGR2", "ST6GALNAC1", "CLDN10", "TCN1",
  "PRXL2A", "MUC16", "SAT1", "XBP1", "PTGS2", "CYP1B1", "CLDN7", "IDO1", "SOD2", "WFDC2", "MUC1", "SERPINA1", "PIGR",
  "HPRT1", "SUFU", "OPRK1", "CBR3", "S100P", "SCGB2A2", "ABCG1", "PAEP", "DPP4", "GPX3", "PTPRR", "FGF7", "FXYD2",
  "IL32", "WNT7A", "LGR5", "MMP7", "TNF", "LDHA", "GPX1", "SLPI", "TMPRSS4",
  "CP", "FTH1", "PDZK1IP1", "DUSP1", "DDIT4", "XDH", "CD24", "SLC34A2", "RARRES1", "CLDN4", "HSPA8",
  "VTCN1", "CLDN22", "SULT1E1", "LEFTY1", "LGR5", "PTGS1", "IL6",
  "CCNO", "CDC20B", "MUC12", "PIFO", "FOXJ1", "TP73", "C1orf194", "RSPH1",
  "MUC5B", "TFF3", "BPIFB1", "SAA1", "LCN2", "LTF",
  "PGR", "AR", "ESR1",
  "AXIN2", "TRH", "ALDH1A1", "CHD2", "KLK1",
  "C9orf24", "NNMT", "CXCL6", "C3", "SPP1", "ATF3", "ALDH1A1", "CXCL12", "CXCL14", "MT1G", "SERF4", "FOS",
  "MKI67", "TOP2A", "SOX9", "CPM", "FHL2", "PLAU", "PAX2",
  "NUS1", "PRDX1", "ANXA2", "WNT2B",
  "DLX5", "MSX1", "STX18")

volcano_genes_cancer <- c(
  "SLC7A11", "DKK1", "PHLDA1", "KMO", "IHH", "EMID1",
  "HPRT1", "SUFU", "OPRK1", "CBR3", "S100P", "SCGB2A2", "ABCG1", "PAEP", "DPP4", "GPX3", "PTPRR", "FGF7", "FXYD2",
  "IL32", "WNT7A", "LGR5", "MMP7", "TNF",
  "VTCN1", "CLDN22", "SULT1E1", "LEFTY1", "LGR5", "PTGS1", "IL6",
  "CCNO", "CDC20B", "MUC12", "PIFO", "FOXJ1", "TP73", "C1orf194", "RSPH1",
  "MUC5B", "TFF3", "BPIFB1", "SAA1", "LCN2", "LTF",
  "PGR", "AR", "ESR1",
  "AXIN2", "TRH", "ALDH1A1", "CDH2", "KLK1",
  "C9orf24", "NNMT", "CXCL6", "C3", "SPP1", "ATF3", "ALDH1A1", "CXCL12", "CXCL14", "MT1G", "SERF4", "FOS",
  "MKI67", "TOP2A", "SOX9", "CPM", "FHL2", "PLAU", "PAX2",
  "NUS1", "PRDX1", "RAB11A", "ANXA2", "WNT2B",
  "DLX5", "MSX1", "STX18",
  "CP", "C12orf75", "KIF12", "SPP1", "PRAME", "SCGB2A1", "MSX2", "DKK4", "PTHLH",
  "KRT5")
