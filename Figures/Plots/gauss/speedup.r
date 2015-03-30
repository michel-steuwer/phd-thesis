require('ggplot2')
require('grid')
require('reshape2')

data <- read.csv("speedup.csv", sep=";", comment.char="#", header=TRUE, row.names=NULL)

rownumbers <- as.integer(row.names(data))

# ====Default settins====
theme <- theme_bw() +
  theme(text = element_text(size = 18),
        axis.title = element_text(size = rel(1.125), vjust = 0.5),
        panel.border = element_rect(linetype = "solid", colour = "black", size = 1.5),
        plot.margin = unit(c(0.1,0.1,0.1,0.1), 'cm'),
        legend.position="right",
        legend.title = element_blank(),
        strip.background = element_rect(colour = "black", fill = "white", size = 1.5))

labs <- labs(x = "Size of Stencil Shape", y = "Speedup")

# create plot
plot <- ggplot(data, aes(x = reorder(Radius, rownumbers), y = value, group=Devices, color=Devices, fill=Devices)) +
  geom_line(aes(linetype=Devices)) +
  geom_point(size=6, aes(shape=Devices)) +
  scale_y_continuous(expand = c(0,0), limits = c(0,4)) +
  scale_x_discrete(expand=c(0,0.5)) +
  scale_color_manual(values=c("#fcae91", "#fb6a4a", "#de2d26", "#a50f15")) +
  scale_fill_manual(values=c("#fcae91", "#fb6a4a", "#de2d26", "#a50f15")) +
  scale_shape_manual(values=c(21,24,22,23)) +
  theme + labs

# save plot to file
ggsave(file = "gauss_speedup.pdf", width = 8, height = 4)

plot
