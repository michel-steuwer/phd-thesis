require('ggplot2')
require('grid')
require('reshape2')

# row.names = NULL forces numbering of the lines and, thus, preserves the order
performance <- read.csv("reduce.csv", sep=";", comment.char="#", header=TRUE, row.names=NULL)
#performance <- melt(performance)
#colnames(performance) <- c("Size", "Versions", "value")

rownumbers <- as.integer(row.names(performance))

# ====Default settins====
theme <- theme_bw() +
  theme(text = element_text(size = 18),
        axis.title = element_text(size = rel(1.125), vjust = 1),
        axis.text.x = element_text(angle = 45, vjust = 0.7),
        panel.border = element_rect(linetype = "solid", colour = "black", size = 1.5),
        plot.margin = unit(c(2,1.2,0,1), 'cm'),
        legend.position="top",
        legend.title = element_blank(),
        strip.background = element_rect(colour = "black", fill = "white", size = 1.5))

labs <- labs(x = "Data Size", y = "Relative Runtime")

# create plot
plot <- ggplot(performance, aes(x = reorder(Size, rownumbers), y = factor, group=group, color=Version)) +
  geom_line(aes(linetype=Version)) +
  geom_point(size=6, aes(shape=Version)) +
  scale_y_continuous(limits=c(0, 8), breaks=c(1, 2, 4, 6, 8)) +
  scale_x_discrete(expand=c(0,0.5)) +
  scale_color_manual(values=c("#fdcc8a", "#fc8d59", "#d7301f")) +
  facet_grid(. ~ Benchmark) + theme + labs

# save plot to file
ggsave(file = "reduce.pdf", width = 8, height = 6)

plot

