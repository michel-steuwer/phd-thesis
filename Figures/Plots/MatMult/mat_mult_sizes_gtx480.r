library(ggplot2)
library(gridExtra)

format_decimal <- function(n){
    function(x) format(x,nsmall = n,scientific = FALSE)
}
my_levels <- c("OpenCL ", "Optimized OpenCL  ", "CUBLAS ", "clBLAS ", "Generic allpairs skeleton  ", "Allpairs skeleton with zip-reduce  ")

colors <- scale_fill_manual(values=c("#b35806", "#f1a340", "#fee0b6", "#d8daeb", "#998ec3", "#542788"))

# 1024 x 1024
data1 <- read.table("mat_mult_sizes_gtx480.txt", header=TRUE, sep=",")
data1$Program <- factor(data1$Program, levels = my_levels)
data1$Size <- factor(data1$Size, levels = c("1024 x 1024"))

plot1 <- ggplot(na.omit(data1), aes(x=Size, y=Time, fill=Program))
plot1 <- plot1 + geom_bar(position="dodge", color="black", stat = "identity")
plot1 <- plot1 + colors
plot1 <- plot1 + xlab("") + theme(axis.title.y = element_blank())
plot1 <- plot1 + theme(legend.title=element_blank(), legend.background=element_blank(), legend.position="bottom", legend.text = element_text(size = 8))

# extract legend
tmp <- ggplot_gtable(ggplot_build(plot1))
leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
legend <- tmp$grobs[[leg]]

plot1 <- plot1 + theme(legend.title=element_blank(), legend.background=element_blank(), legend.position="none")



# 2048 x 2048
data2 <- read.table("mat_mult_sizes_gtx480.txt", header=TRUE, sep=",")
data2$Program <- factor(data2$Program, levels = my_levels)
data2$Size <- factor(data2$Size, levels = c("2048 x 2048"))

plot2 <- ggplot(na.omit(data2), aes(x=Size, y=Time, fill=Program))
plot2 <- plot2 + geom_bar(position="dodge", color="black", stat = "identity")
plot2 <- plot2 + colors
plot2 <- plot2 + xlab("") + theme(axis.title.y = element_blank())
plot2 <- plot2 + theme(legend.title=element_blank(), legend.background=element_blank(), legend.position="none")



# 4096 x 4096
data4 <- read.table("mat_mult_sizes_gtx480.txt", header=TRUE, sep=",")
data4$Program <- factor(data4$Program, levels = my_levels)
data4$Size <- factor(data4$Size, levels = c("4096 x 4096"))

plot4 <- ggplot(na.omit(data4), aes(x=Size, y=Time, fill=Program))
plot4 <- plot4 + geom_bar(position="dodge", color="black", stat = "identity")
plot4 <- plot4 + colors
plot4 <- plot4 + xlab("Matrix Size") + theme(axis.title.y = element_blank())
plot4 <- plot4 + theme(axis.title.x = element_text(vjust = -0.5))
plot4 <- plot4 + theme(legend.title=element_blank(), legend.background=element_blank(), legend.position="none")



# 8192 x 8192
data8 <- read.table("mat_mult_sizes_gtx480.txt", header=TRUE, sep=",")
data8$Program <- factor(data8$Program, levels = my_levels)
data8$Size <- factor(data8$Size, levels = c("8192 x 8192"))

plot8 <- ggplot(na.omit(data8), aes(x=Size, y=Time, fill=Program))
plot8 <- plot8 + geom_bar(position="dodge", color="black", stat = "identity")
plot8 <- plot8 + colors
plot8 <- plot8 + xlab("") + theme(axis.title.y = element_blank())
plot8 <- plot8 + theme(legend.title=element_blank(), legend.background=element_blank(), legend.position="none")



# 10000 x 10000
data10 <- read.table("mat_mult_sizes_gtx480.txt", header=TRUE, sep=",")
data10$Program <- factor(data10$Program, levels = my_levels)
data10$Size <- factor(data10$Size, levels = c("16384 x 16384"))

plot10 <- ggplot(na.omit(data10), aes(x=Size, y=Time, fill=Program))
plot10 <- plot10 + geom_bar(position="dodge", color="black", stat = "identity")
plot10 <- plot10 + colors
plot10 <- plot10 + xlab("") + theme(axis.title.y = element_blank())
plot10 <- plot10 + theme(legend.title=element_blank(), legend.background=element_blank(), legend.position="none")



pdf("mat_mult_sizes_gtx480.pdf", width=8, height=4)
plot <- grid.arrange(legend,
										 arrangeGrob(plot1, plot2, plot4, plot8, plot10,
                                 widths=c(1.02, 1.02, 1, 0.98, 0.98),
                                 left="Runtime in Seconds", nrow=1),
                     heights=c(0.1,0.9),
									   ncol=1)
dev.off()

plot
