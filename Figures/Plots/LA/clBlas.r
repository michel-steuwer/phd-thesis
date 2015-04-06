require('ggplot2')
require('grid')
require('reshape2')

strwr <- function(str) gsub("\\|", "\n", str)

data <- read.csv("clBlas.csv", sep=";", comment.char="#", header=TRUE, row.names=NULL)
data$Platform  <- factor(data$Platform, levels = c("Nvidia GPU", "AMD GPU", "Intel CPU"))
data$Benchmark <- factor(data$Benchmark, levels = c("scal-small", "scal-large", "asum-small", "asum-large", "dot-small", "dot-large", "gemv-small", "gemv-large"))

rownumbers <- as.integer(row.names(data))

# ====Default settins====
theme <- theme_bw() +
  theme(text = element_text(size = 22),
        axis.title = element_text(size = rel(1.125), vjust = 1),
        panel.border = element_rect(linetype = "solid", colour = "black", size = 1.5),
        plot.margin = unit(c(0.5,0.1,0.1,0.1), 'cm'),
        legend.position="top",
        legend.title = element_blank(),
        strip.background = element_rect(colour = "black", fill = "white", size = 1.5))

labs <- labs(x = "", y = "Speedup")

# create plot
plot <- ggplot(data, aes(x = Benchmark, y = value, fill=Platform)) +
  geom_bar(position="dodge", stat = "identity", width=.5) +
  scale_y_continuous(expand = c(0,0), limits = c(0,4)) +
  scale_x_discrete(labels= strwr(levels(data$Benchmark)), expand=c(0,0.5)) +
  scale_fill_manual(values=c("#fcbba1", "#fb6a4a", "#a50f15")) +
  theme + labs

# save plot to file
ggsave(file = "LA_vs_clBlas.pdf", width = 8, height = 6)

plot
