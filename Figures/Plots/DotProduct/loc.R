library(ggplot2)

# replace | with newline
#strwr <- function(str) gsub("\\|", "\n", str)
#my_levels <- c("OpenCL", "Optimized OpenCL", "cuBLAS", "clBLAS", "Generic allpairs|skeleton", "Allpairs skeleton|with zip-reduce")

data <- read.table("loc.csv", header=TRUE, sep=",")
#data$Program <- factor(data$Program, levels = my_levels)

plot <- ggplot(na.omit(data), aes(x=Program, y=Lines, fill=Device))
plot <- plot + geom_bar(color="black", width=.5, stat = "identity")
plot <- plot + scale_fill_brewer(palette="PuOr")
plot <- plot + xlab("") + ylab("Lines of Code")
plot <- plot + scale_x_discrete(labels= strwr(levels(data$Program)))
plot <- plot + theme(text = element_text(size = 14), legend.title=element_blank(), legend.background=element_blank(), legend.position="bottom")
plot <- plot + guides(fill = guide_legend(reverse=TRUE))

pdf("dot_loc.pdf", width=8, height=4)
plot
dev.off()

plot
