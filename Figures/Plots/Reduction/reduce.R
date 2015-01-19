require('ggplot2')
require('grid')

data <- read.csv("reduce.csv",
                 sep=";",
                 comment.char="#",
                 header=TRUE,
                 row.names=NULL) # forces numbering of the lines and, thus, preserves the order
rownumbers <- as.integer(row.names(data))

# ==== NVIDIA plot ====
# rename BLAS to cuBLAS
levels(data$Kernel)[levels(data$Kernel) == "BLAS"] <- "cuBLAS"
# bandwidth limit
bw <- 177.4
# create plot
pNV <- ggplot(data, aes(x = reorder(Kernel, rownumbers), y = GTX480)) +
       geom_bar(stat = "identity", fill="#74C476") +
       labs(#title = "",
            x = "",
            y = "Bandwidth (GB/s)") +
        scale_y_continuous( expand = c(0,0), limits = c(0,200) ) +
        geom_hline(yintercept = bw) +
        annotate("text", x = 4, y= bw+10, label = "Hardware Bandwidth Limit", size=7) +
        theme_bw() +
        theme(text = element_text(size=22),
              axis.title = element_text(size = rel(1.125), vjust = 3),
              axis.text.x = element_text(angle = 45, vjust = 0.5),
              panel.border = element_rect(linetype = "solid", colour = "black", size=1.5),
              plot.margin=unit(c(0.5,0.5,0.5,1),'cm'))
# save plot to file
ggsave(file = "reduce_nv.pdf", width=9, height=6)

# ==== AMD plot ====
# rename cuBLAS to clBLAS
levels(data$Kernel)[levels(data$Kernel) == "cuBLAS"] <- "clBLAS"
# bandwidth limit
bw <- 264
# create plot
pAMD <- ggplot(data, aes(x = reorder(Kernel, rownumbers), y = HD7970)) +
        geom_bar(stat = "identity", fill="#de2d26") +
        labs(#title = "",
          x = "",
          y = "Bandwidth (GB/s)") +
        scale_y_continuous( expand = c(0,0), limits = c(0,300) ) +
        geom_hline(yintercept = bw) +
        annotate("text", x = 4, y= bw+15, label = "Hardware Bandwidth Limit", size=7) +
        theme_bw() +
        theme(text = element_text(size=22),
              axis.title = element_text(size = rel(1.125), vjust = 3),
              axis.text.x = element_text(angle = 45, vjust = 0.5),
              panel.border = element_rect(linetype = "solid", colour = "black", size=1.5),
              plot.margin=unit(c(0.5,0.5,0.5,1),'cm'))
# save plot to file
ggsave(file = "reduce_amd.pdf", width=9, height=6)

# ==== Intel plot ====
# rename clBLAS to MKL
levels(data$Kernel)[levels(data$Kernel) == "clBLAS"] <- "MKL"
# bandwidth limit
bw <- 25.6
# create plot
pIntel <- ggplot(data, aes(x = reorder(Kernel, rownumbers), y = E5530)) +
  geom_bar(stat = "identity", fill="#3182bd") +
  labs(#title = "",
    x = "",
    y = "Bandwidth (GB/s)") +
  scale_y_continuous( expand = c(0,0), limits = c(0,30) ) +
  geom_hline(yintercept = bw) +
  annotate("text", x = 4, y= bw+1.5, label = "Hardware Bandwidth Limit", size=7) +
  annotate("text", x = 5, y= 1.5, label = "Failed", size=7) +
  annotate("text", x = 6, y= 1.5, label = "Failed", size=7) +
  annotate("text", x = 7, y= 1.5, label = "Failed", size=7) +
  theme_bw() +
  theme(text = element_text(size=22),
        axis.title = element_text(size = rel(1.125), vjust = 3.5),
        axis.text.x = element_text(angle = 45, vjust = 0.5),
        panel.border = element_rect(linetype = "solid", colour = "black", size=1.5),
        plot.margin=unit(c(0.5,0.5,0.5,1.25),'cm'))
# save plot to file
ggsave(file = "reduce_intel.pdf", width=9, height=6)
