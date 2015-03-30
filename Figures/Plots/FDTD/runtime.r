require('ggplot2')
require('grid')
require('reshape2')

data <- read.csv("runtime.csv", sep=";", comment.char="#", header=TRUE, row.names=NULL)
data$Kind <- factor(data$Kind, levels = c("Map", "First Stencil", "Second Stencil"))

# ====Default settins====
theme <- theme_bw() +
  theme(text = element_text(size = 18),
        axis.title = element_text(size = rel(1.125), vjust = 1),
        panel.border = element_rect(linetype = "solid", colour = "black", size = 1.5),
        plot.margin = unit(c(0.5,0,0.2,0.1), 'cm'),
        legend.position="right",
        legend.title = element_blank(),
        strip.background = element_rect(colour = "black", fill = "white", size = 1.5))

labs <- labs(x = "", y = "Runtime for one iteration in msec")

# create plot
plot <- ggplot(data, aes(x = Version, y = value, fill=Kind)) +
  geom_bar(stat = "identity", width=.75) +
  scale_y_continuous(expand = c(0,0), limits = c(0,5)) +
  scale_x_discrete(expand=c(0,0.5)) +
  scale_fill_manual(values=c("#fc9272", "#fb6a4a", "#de2d26")) +
  theme + labs


# save plot to file
ggsave(file = "fdtd_runtime.pdf", width = 6, height = 6)

plot
