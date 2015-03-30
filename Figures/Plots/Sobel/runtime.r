require('ggplot2')
require('grid')
require('reshape2')

data <- read.csv("runtime.csv", sep=";", comment.char="#", header=TRUE, row.names=NULL)
data$Version <- factor(data$Version, levels = c("OpenCL (AMD)", "OpenCL (Nvidia)", "SkelCL"))

rownumbers <- as.integer(row.names(data))

# ====Default settins====
theme <- theme_bw() +
  theme(text = element_text(size = 18),
        axis.title = element_text(size = rel(1.125), vjust = 1),
        panel.border = element_rect(linetype = "solid", colour = "black", size = 1.5),
        plot.margin = unit(c(0.5,0.1,0.1,0.1), 'cm'),
        legend.position="none",
        strip.background = element_rect(colour = "black", fill = "white", size = 1.5))

labs <- labs(x = "", y = "Runtime in msec")

# create plot
plot <- ggplot(data, aes(x = Version, y = value, fill=Version)) +
  geom_bar(position="dodge", stat = "identity", width=.5) +
  scale_y_continuous(expand = c(0,0), limits = c(0,0.25)) +
  scale_x_discrete(expand=c(0,0.5)) +
  scale_fill_manual(values=c("#fcae91", "#fb6a4a", "#de2d26", "#a50f15")) +
  theme + labs

# save plot to file
ggsave(file = "sobel_runtime.pdf", width = 6, height = 4)

plot
