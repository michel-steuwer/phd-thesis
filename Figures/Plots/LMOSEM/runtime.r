require('ggplot2')
require('grid')
require('reshape2')

data <- read.csv("runtime.csv", sep=";", comment.char="#", header=TRUE, row.names=NULL)
#data$Version <- factor(data$Version, levels = c("OpenCL Global Memory", "OpenCL Local Memory", "MapOverlap", "Stencil"))
#data$value <- data$value/1000

rownumbers <- as.integer(row.names(data))

# ====Default settins====
theme <- theme_bw() +
  theme(text = element_text(size = 18),
        axis.title = element_text(size = rel(1.125), vjust = 0.5),
        panel.border = element_rect(linetype = "solid", colour = "black", size = 1.5),
        plot.margin = unit(c(0.1,0.1,0.1,0.1), 'cm'),
        legend.position="none",
        legend.title = element_blank(),
        strip.background = element_rect(colour = "black", fill = "white", size = 1.5))

labs <- labs(x = "Number of GPUs", y = "Runtime in seconds")

# create plot
plot <- ggplot(data, aes(x = factor(Devices), y = value, group=Version, fill=Version)) +
  geom_bar(position="dodge", stat = "identity", width=0.75, color="black") +
  scale_y_continuous(expand = c(0,0), limits = c(0,4)) +
  scale_x_discrete(expand=c(0,0.5)) +
  scale_fill_manual(values=c("#fb6a4a", "#de2d26")) +
  facet_grid(. ~ Version) +
  theme + labs

# save plot to file
ggsave(file = "lmosem_runtime.pdf", width = 8, height = 5)

plot
