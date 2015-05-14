require('ggplot2')
require('grid')
require('reshape2')

strwr <- function(str) gsub("\\|", "\n", str)

data <- read.csv("results.csv", sep=";", comment.char="#", header=TRUE, row.names=NULL)
data$Platform <- factor(data$Platform, levels = c("Nvidia GPU", "AMD GPU", "Intel CPU"))
data$Version <- factor(data$Version, levels = c("OpenCL", "Generated"))

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
plot <- ggplot(data, aes(x = Platform, y = value, fill=Version)) +
  geom_bar(position="dodge", stat = "identity", width=.5) +
  scale_y_continuous(expand = c(0,0), limits = c(0,1.5)) +
  scale_x_discrete(labels= strwr(levels(data$Platform)), expand=c(0,0.5)) +
  geom_hline(yintercept=1) +
  scale_fill_manual(values=c("#fc9272", "#de2d26")) +
  theme + labs

# save plot to file
ggsave(file = "md_speedup.pdf", width = 6, height = 5)

plot
