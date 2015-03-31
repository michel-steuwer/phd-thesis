require('ggplot2')

data <- read.table("loc.csv", header=TRUE, sep=",")

theme <- theme_bw() +
  theme(text = element_text(size = 16),
        axis.title = element_text(size = rel(1.125), vjust = 1),
        axis.text.x = element_text(size = rel(0.9)),
        legend.text = element_text(size = rel(0.75)),
        panel.border = element_rect(linetype = "solid", colour = "black", size = 1.5),
        plot.margin = unit(c(2,1.2,0,1), 'cm'),
        legend.position="right",
        legend.title = element_blank(),
        strip.background = element_rect(colour = "black", fill = "white", size = 1.5))

labs <- labs(x = "", y = "Lines of Code")

# create plot
plot <- ggplot(na.omit(data), aes(x=Program, y=Lines, fill=Device)) +
  geom_bar(color="black", width=.5, stat = "identity") +
  scale_fill_manual(values=c("#fdae6b", "#fee6ce")) + #"#e6550d", 
  scale_x_discrete() +
  facet_grid(. ~ Benchmark) + theme + labs

# save plot to file
ggsave(file = "la_loc.pdf", width = 8, height = 4)

plot
