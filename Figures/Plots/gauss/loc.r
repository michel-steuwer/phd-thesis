library(ggplot2)

# replace | with newline
strwr <- function(str) gsub("\\|", "\n", str)

my_levels <- c("OpenCL global memory", "|OpenCL local memory", "MapOverlap", "|Stencil")

data <- read.csv("loc.csv", sep=";", comment.char="#", header=TRUE, row.names=NULL)
data$Version <- factor(data$Version, levels = my_levels)

theme <- theme_bw() +
  theme(text = element_text(size = 14),
        axis.title = element_text(size = rel(1.125), vjust = 1),
        axis.text.x = element_text(size = rel(1)),
        legend.text = element_text(size = rel(0.75)),
        panel.border = element_rect(linetype = "solid", colour = "black", size = 1.5),
        plot.margin = unit(c(2,1.2,0,1), 'cm'),
        legend.position="right",
        strip.background = element_rect(colour = "black", fill = "white", size = 1.5))

labs <- labs(x = "", y = "Lines of Code")

# create plot
plot <- ggplot(na.omit(data), aes(x=Version, y=value, fill=Kind)) +
  geom_bar(color="black", width=.5, stat = "identity") +
  scale_fill_manual(values=c("#fee6ce", "#fdae6b")) +
  scale_x_discrete(labels= strwr(levels(data$Version))) + theme + labs

# save plot to file
ggsave(file = "gauss_loc.pdf", width = 8, height = 4)

plot
