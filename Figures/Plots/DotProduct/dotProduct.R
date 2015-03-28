require('ggplot2')
require('grid')
require('reshape2')

# row.names = NULL forces numbering of the lines and, thus, preserves the order
performance <- read.csv("dotProduct.csv", sep=";", comment.char="#", header=TRUE, row.names=NULL)
performance <- melt(performance)
colnames(performance) <- c("Size", "Version", "value")

rownumbers <- as.integer(row.names(performance))

# ====Default settins====
theme <- theme_bw() +
  theme(text = element_text(size = 20),
        axis.title = element_text(size = rel(1.125), vjust = 1),
        axis.text.x = element_text(angle = 45, vjust = 0.7),
        panel.border = element_rect(linetype = "solid", colour = "black", size = 1.5),
        plot.margin = unit(c(2,1.2,0,1), 'cm'),
        legend.position="top")

labs <- labs(x = "Data Size", y = "Runtime in ms  (log scale)")

# create plot
plot <- ggplot(performance, aes(x = reorder(Size, rownumbers), y = value, group=Version, color = Version)) +
  geom_line(aes(linetype=Version)) +
  geom_point(size=6, aes(shape=Version)) +
  scale_y_log10(expand = c(0,0), limits = c(1,1000)) +
  scale_x_discrete(expand=c(0,0.1)) +
  labs + theme

# save plot to file
ggsave(file = "dotProduct.pdf", width = 6, height = 5)

plot
