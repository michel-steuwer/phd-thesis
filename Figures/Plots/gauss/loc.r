library(ggplot2)
library(gridExtra)

# replace | with newline
strwr <- function(str) gsub("\\|", "\n", str)

my_levels <- c("OpenCL global memory", "|OpenCL local memory", "MapOverlap", "Stencil")

data <- read.csv("loc.csv", sep=";", comment.char="#", header=TRUE, row.names=NULL)
data$Version <- factor(data$Version, levels = my_levels)

theme <- theme_bw() +
  theme(text = element_text(size = 14),
        axis.title = element_text(size = rel(1.125), vjust = 1),
        axis.text.x = element_text(size = rel(1)),
        legend.text = element_text(size = rel(0.75)),
        panel.border = element_rect(linetype = "solid", colour = "black", size = 1.5),
        plot.margin = unit(c(1,-1,0,1), 'cm'),
        legend.position="right",
        legend.title = element_blank(),
        strip.background = element_rect(colour = "black", fill = "white", size = 1.5))

labs <- labs(x = "", y = "Lines of Code")

# create plot
plot <- ggplot(na.omit(data), aes(x=Version, y=value, fill=Kind)) +
  geom_bar(color="black", width=.5, stat = "identity") +
  scale_fill_manual(values=c("#fdae6b", "#fee6ce")) +
  scale_x_discrete(labels= strwr(levels(data$Version))) + theme + labs

aranged <- arrangeGrob(plot, legend=textGrob("SkelCL", gp = gpar(cex = 1.25), x = unit(-2.4, "in"), y = unit(0.25, "in")))

# Printing the graph works:
print(aranged)

ggsave <- ggplot2::ggsave; body(ggsave) <- body(ggplot2::ggsave)[-2]

# save plot to file
ggsave(file = "gauss_loc.pdf", plot = aranged, width = 8, height = 4, units = c("in"))

plot
