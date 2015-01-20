require('ggplot2')
require('grid')

# row.names = NULL forces numbering of the lines and, thus, preserves the order
bandwidth <- read.csv("reduce.csv", sep=";", comment.char="#", header=TRUE, row.names=NULL)
rownumbers <- as.integer(row.names(bandwidth))

hwFeatures <- read.csv("hwFeatures.csv", sep=";", comment.char="#", header=TRUE, row.names=NULL)
bws <- subset(hwFeatures, Feature=="Hardware Bandwidth Limit")

# ====Default settins====
theme <- theme_bw() +
         theme(text = element_text(size = 22),
               axis.title = element_text(size = rel(1.125), vjust = 3),
               axis.text.x = element_text(angle = 45, vjust = 0.5),
               panel.border = element_rect(linetype = "solid", colour = "black", size = 1.5),
               plot.margin = unit(c(2,0.5,-0.75,1), 'cm'))

labs <- labs(x = "", y = "Bandwidth (GB/s)")

# ==== NVIDIA plot ====
# rename BLAS to cuBLAS
levels(bandwidth$Kernel)[levels(bandwidth$Kernel) == "BLAS"] <- "cuBLAS"
# bandwidth limit
# create plot
pNV <- ggplot(bandwidth, aes(x = reorder(Kernel, rownumbers), y = GTX480)) +
       geom_bar(stat = "identity", fill = "#74C476") +
       scale_y_continuous(expand = c(0,0), limits = c(0,200)) +
       geom_hline(aes(yintercept = GTX480), data = bws) +
       geom_text(aes(x = 4, y = GTX480, label = Feature), data = bws, size = 7, vjust = -.5) +
       labs + theme

# save plot to file
ggsave(file = "reduce_nv.pdf", width = 9, height = 6)


# ==== AMD plot ====
# rename cuBLAS to clBLAS
levels(bandwidth$Kernel)[levels(bandwidth$Kernel) == "cuBLAS"] <- "clBLAS"
# create plot
pAMD <- ggplot(bandwidth, aes(x = reorder(Kernel, rownumbers), y = HD7970)) +
        geom_bar(stat = "identity", fill = "#de2d26") +
        scale_y_continuous(expand = c(0,0), limits = c(0,300)) +
        geom_hline(aes(yintercept = HD7970), data = bws) +
        geom_text(aes(x = 4, y = HD7970, label = Feature), data = bws, size = 7, vjust = -.5) +
        labs + theme
# save plot to file
ggsave(file = "reduce_amd.pdf", width = 9, height = 6)

# ==== Intel plot ====
# rename clBLAS to MKL
levels(bandwidth$Kernel)[levels(bandwidth$Kernel) == "clBLAS"] <- "MKL"
# create plot
pIntel <- ggplot(bandwidth, aes(x = reorder(Kernel, rownumbers), y = E5530)) +
          geom_bar(stat = "identity", fill = "#3182bd") +
          scale_y_continuous(expand = c(0,0), limits = c(0,30)) +
          geom_hline(aes(yintercept = E5530), data = bws) +
          geom_text(aes(x = 4, y = E5530, label = Feature), data = bws, size = 7, vjust = -.5) +
          annotate("text", x = 5, y = 1.5, label = "Failed", size = 7) +
          annotate("text", x = 6, y = 1.5, label = "Failed", size = 7) +
          annotate("text", x = 7, y = 1.5, label = "Failed", size = 7) +
          labs + theme +
          # override theme defaults set above
          theme(axis.title = element_text(size = rel(1.125), vjust = 4.35),
                plot.margin = unit(c(2,0.5,-0.75,1.35), 'cm'))

# save plot to file
ggsave(file = "reduce_intel.pdf", width = 9, height = 6)
