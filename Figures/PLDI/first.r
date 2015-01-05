library(ggplot2)
library(gridExtra)

versions <- c("Nvidia A", "Nvidia B", "Nvidia C", "AMD", "Thrust", "cuBlas", "clBlas", "auto-expl")
comparisons <- c(" Low-level Expressions", " Automatic Exploration")
types <- c(" Hand-written", " Generated", " Library")

# dark, light, medium
colors <- c("#A63603", "#FEEDDE", "#FD8D3C")

# NVIDIA
data1 <- read.table("results.csv", header=TRUE, sep=",")
data1$Version <- factor(data1$Version, levels = versions)
data1$Platform <- factor(data1$Platform, levels = c(" Nvidia"))
data1$Comparison <- factor(data1$Comparison, levels = comparisons)
data1$Type <- factor(data1$Type, levels = types)

left1 <- data1
left1$Comparison <- factor(left1$Comparison,
                           levels = c(" Low-level Expressions"))
right1 <- data1
right1$Comparison <- factor(right1$Comparison,
                            levels = c(" Automatic Exploration"))

plot1 <- ggplot(na.omit(data1), aes(x=Version, y=Bandwidth, fill=Type)) +
         facet_grid(. ~ Comparison, scales="free_x") +
         expand_limits(y=200) +
         scale_y_continuous(breaks=c(0,50,100,150,200), expand=c(0,0)) +
         geom_hline(aes(yintercept=177.4)) +
         geom_text(data=na.omit(left1), label="Hardware Bandwidth Limit",
                   x = 2.4, y = 184.5, size = 3) +
         geom_bar(position="dodge", stat="identity", color="black",
                  data=na.omit(left1), size=.3) +
         geom_bar(position="dodge", stat="identity", color="black",
                  data=na.omit(right1), size=.3,
                  width=.5) +
         scale_fill_manual(values=colors) +
         ylab("Bandwidth (GB/s)") +
         theme_bw() +
         theme(legend.title=element_blank(),
               legend.background=element_blank(),
               legend.position="top",
               legend.text = element_text(size = 9),
               axis.title.x = element_blank(),
               axis.text.x = element_text(angle=45, vjust=1, hjust=1),
               axis.ticks = element_line(size=.5),
               panel.grid.major.x = element_blank(),
               panel.grid.minor.x = element_blank(),
               panel.grid.major.y = element_line(color="darkgray", size=.2,
                                                 linetype="dashed"),
               panel.grid.minor.y = element_line(color="darkgray", size=.1,
                                                 linetype="dashed"),
               panel.border = element_blank(),
               axis.line = element_line(size=.5),
               panel.margin = unit(1, "lines"),
               strip.background = element_blank(),
               strip.text = element_text()
               )


# extract legend
tmp <- ggplot_gtable(ggplot_build(plot1))
leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
legend <- tmp$grobs[[leg]]

plot1 <- plot1 + theme(legend.position="none")

# AMD
data2 <- read.table("results.csv", header=TRUE, sep=",")
data2$Version <- factor(data2$Version, levels = versions)
data2$Platform <- factor(data2$Platform, levels = c(" AMD"))
data2$Comparison <- factor(data2$Comparison, levels = comparisons)
data2$Type <- factor(data2$Type, levels = types)

left2 <- data2
left2$Comparison <- factor(left2$Comparison,
                           levels = c(" Low-level Expressions"))
right2 <- data2
right2$Comparison <- factor(right2$Comparison,
                            levels = c(" Automatic Exploration"))

plot2 <- ggplot(na.omit(data2), aes(x=Version, y=Bandwidth, fill=Type)) + 
         facet_grid(. ~ Comparison, scales="free_x") +
         expand_limits(y=300) +
         scale_y_continuous(breaks=c(0,50,100,150,200,250,300), expand=c(0,0)) +
         geom_hline(aes(yintercept=265)) +
         geom_text(data=na.omit(left1), label="Hardware Bandwidth Limit",
                   x = 2.4, y = 275, size = 3) +
         geom_bar(position="dodge", stat="identity", color="black",
                  data=na.omit(left2), size=.3) +
         geom_bar(position="dodge", stat="identity", color="black",
                  data=na.omit(right2), size=.3,
                  width=.5) +
         scale_fill_manual(values=colors) +
         theme_bw() + 
         theme(legend.title=element_blank(),
               legend.background=element_blank(),
               legend.position="none",
               legend.text = element_text(size = 9),
               axis.title.x = element_blank(),
               axis.text.x = element_text(angle=45, vjust=1, hjust=1),
               axis.ticks = element_line(size=.5),
               panel.grid.major.x = element_blank(),
               panel.grid.minor.x = element_blank(),
               panel.grid.major.y = element_line(color="darkgray", size=.2,
                                                 linetype="dashed"),
               panel.grid.minor.y = element_line(color="darkgray", size=.1,
                                                 linetype="dashed"),
               panel.border = element_blank(),
               axis.line = element_line(size=.5),
               panel.margin = unit(1, "lines"),
               strip.background = element_blank()
               )

pdf("first.pdf", width=9, height=4)
#grid.draw(grob)
plot <- grid.arrange(plot1, plot2, ncol=2)
#plot <- grid.arrange(legend,
#										 arrangeGrob(plot1, plot2,
#                                 widths=c(1.1, 1, 1, 0.98, 1.02),
#                                 left="Bandwidth", nrow=1),
#                     heights=c(0.1,0.9),
#									   ncol=1)
dev.off()
