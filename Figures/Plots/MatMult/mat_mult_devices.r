library(ggplot2)
library(gridExtra)

my_levels <- c("Generic allpairs skeleton   ", "Allpairs skeleton with zip-reduce   ")

colors <- scale_fill_manual(values=c("#998ec3", "#542788"))

data4 <- read.table("mat_mult_devices.txt", header=TRUE, sep=",")
data4$Size <- factor(data4$Size, levels = c("4096 x 4096"))
data4$Devices <- factor(data4$Devices, levels = c("1", "2", "3", "4"))
data4$Program <- factor(data4$Program, levels = my_levels)

plot4 <- ggplot(na.omit(data4), aes(x=Devices, y=Time, fill=Program))
plot4 <- plot4 + labs(title="4096 x 4096")
plot4 <- plot4 + geom_bar(position="dodge", color="black", stat = "identity")
plot4 <- plot4 + colors
plot4 <- plot4 + xlab("") + theme(axis.title.y = element_blank())
plot4 <- plot4 + theme(legend.title=element_blank(), legend.background=element_blank(), legend.position="bottom")

tmp <- ggplot_gtable(ggplot_build(plot4))
leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
legend <- tmp$grobs[[leg]]

plot4 <- plot4 + theme(legend.title=element_blank(), legend.background=element_blank(), legend.position="none")



data8 <- read.table("mat_mult_devices.txt", header=TRUE, sep=",")
data8$Size <- factor(data8$Size, levels = c("8192 x 8192"))
data8$Devices <- factor(data8$Devices, levels = c("1", "2", "3", "4"))
data8$Program <- factor(data8$Program, levels = my_levels)

plot8 <- ggplot(na.omit(data8), aes(x=Devices, y=Time, fill=Program))
plot8 <- plot8 + labs(title="8192 x 8192")
plot8 <- plot8 + geom_bar(position="dodge", color="black", stat = "identity")
plot8 <- plot8 + colors
plot8 <- plot8 + theme(legend.title=element_blank(), legend.background=element_blank(), legend.position="none")
plot8 <- plot8 + xlab("Number of GPUs") + theme(axis.title.y = element_blank())
plot8 <- plot8 + theme(axis.title.x = element_text(vjust = -0.5))


data16 <- read.table("mat_mult_devices.txt", header=TRUE, sep=",")
data16$Size <- factor(data16$Size, levels = c("16384 x 16384"))
data16$Devices <- factor(data16$Devices, levels = c("1", "2", "3", "4"))
data16$Program <- factor(data16$Program, levels = my_levels)

plot16 <- ggplot(na.omit(data16), aes(x=Devices, y=Time, fill=Program))
plot16 <- plot16 + labs(title="16384 x 16384")
plot16 <- plot16 + geom_bar(position="dodge", color="black", stat = "identity")
plot16 <- plot16 + colors
plot16 <- plot16 + theme(legend.title=element_blank(), legend.background=element_blank(), legend.position="none")
plot16 <- plot16 + xlab("") + theme(axis.title.y = element_blank())



postscript("mat_mult_devices.ps", horizontal=FALSE, width=8, height=3.5)
plot <- grid.arrange(legend,
                     arrangeGrob(plot4, plot8, plot16, left="Runtime in Seconds", nrow=1),
										 heights=c(0.1,0.9),
									   ncol=1)
dev.off()

pdf("mat_mult_devices.pdf", width=8, height=3.5)
plot <- grid.arrange(legend,
                     arrangeGrob(plot4, plot8, plot16, left="Runtime in Seconds", nrow=1),
										 heights=c(0.1,0.9),
									   ncol=1)
dev.off()
