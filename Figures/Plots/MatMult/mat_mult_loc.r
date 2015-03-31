library(ggplot2)
#library(gridExtra)

# replace | with newline
strwr <- function(str) gsub("\\|", "\n", str)

my_levels <- c("OpenCL", "Optimized OpenCL", "CUBLAS", "clBLAS", "Generic allpairs|skeleton", "Allpairs skeleton|with zip-reduce")

# 1024 x 1024
data <- read.table("mat_mult_loc.csv", header=TRUE, sep=",")
data$Program <- factor(data$Program, levels = my_levels)
#data$Device <- factor(data$Device, levels = c("GPU Code ", "CPU Code "))

theme <- theme_bw() +
  theme(text = element_text(size = 14),
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
  scale_x_discrete(labels= strwr(levels(data$Program))) + theme + labs


#plot <- ggplot(na.omit(data), aes(x=Program, y=Lines, fill=Device))
#plot <- plot + geom_bar(color="black", width=.5, stat = "identity")
#plot <- plot + scale_fill_brewer(palette="PuOr")
#plot <- plot + xlab("") + ylab("Lines of Code")
#plot <- plot + scale_x_discrete(labels= strwr(levels(data$Program)))
#plot <- plot + theme(text = element_text(size = 14), legend.title=element_blank(), legend.background=element_blank(), legend.position="bottom")
#plot <- plot + guides(fill = guide_legend(reverse=TRUE))

# save plot to file
ggsave(file = "mat_mult_loc.pdf", width = 8, height = 5)

plot
