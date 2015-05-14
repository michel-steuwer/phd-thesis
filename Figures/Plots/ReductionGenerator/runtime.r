require('ggplot2')
require('grid')
require('reshape2')

strwr <- function(str) gsub("\\|", "\n", str)

data <- read.csv("runtime.csv", sep=";", comment.char="#", header=TRUE, row.names=NULL)
data$Version <- factor(data$Version, levels = c("Listing 5.2", "|Figure 6.1a", "Listing 5.4", "|Figure 6.1b", "Listing 5.7", "|Figure 6.1c", "Thrust", "|CUBLAS"))
data$Type    <- factor(data$Type, levels = c("Hand-written  ", "Generated  ", "Library  "))

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

labs <- labs(x = "", y = "Bandwidth (GB/s)")

# create plot
plot <- ggplot(data, aes(x = Version, y = value, fill=Type)) +
  geom_bar(position="dodge", stat = "identity", width=.5) +
  geom_hline(yintercept=177.4) +
  annotate("text", x = 2.5, y = 185, label = "Hardware Bandwidth Limit", size = 6) +
  scale_y_continuous(expand = c(0,0), limits = c(0,200)) +
  scale_x_discrete(labels= strwr(levels(data$Version)), expand=c(0,0.5)) +
  #scale_fill_manual(values=c("#fb6a4a", "#de2d26", "#a50f15")) +
  scale_fill_manual(values=c("#fee0d2", "#fc9272", "#de2d26")) +
  theme + labs

# save plot to file
ggsave(file = "reduce_runtime.pdf", width = 8, height = 6)

plot
