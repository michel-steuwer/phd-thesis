require('ggplot2')
require('grid')
require('reshape2')



# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

strwr <- function(str) gsub("\\|", "\n", str)

data <- read.csv("automatic_runtime.csv", sep=";", comment.char="#", header=TRUE, row.names=NULL)
#data$Version <- factor(data$Version, levels = c("Listing 5.2", "|Figure 6.1a", "Listing 5.4", "|Figure 6.1b", "Listing 5.7", "|Figure 6.1c", "Thrust", "|CUBLAS"))

rownumbers <- as.integer(row.names(data))

# ====Default settins====
theme <- theme_bw() +
  theme(text = element_text(size = 20),
        axis.title = element_text(size = rel(1.125), vjust = 1),
        panel.border = element_rect(linetype = "solid", colour = "black", size = 1.5),
        plot.margin = unit(c(0.5,0.1,0.1,0.1), 'cm'),
        legend.position="none",
        legend.title = element_blank(),
        strip.background = element_rect(colour = "black", fill = "white", size = 1.5))

labs <- labs(x = "", y = "Bandwidth (GB/s)")

nvidia <- data[data$Platform == "Nvidia",]
nvidia$Version <- factor(nvidia$Version, levels = c("Generated", "CUBLAS"))
nvidiaPlot <- ggplot(nvidia, aes(x = Version, y = value, fill=Version)) +
  geom_bar(position="dodge", stat = "identity", width=.5) +
  scale_y_continuous(expand = c(0,0), limits = c(0,195.14)) +
  geom_hline(yintercept=177.4) +
  annotate("text", x = 1.5, y = 185, label = "Hardware Bandwidth Limit", size = 5) +
  scale_x_discrete(expand=c(0,0.5)) +
  scale_fill_manual(values=c("#de2d26", "#a50f15")) +
  theme + labs

amd <- data[data$Platform == "AMD",]
amd$Version <- factor(amd$Version, levels = c("Generated", "clBLAS"))
amdPlot <- ggplot(amd, aes(x = Version, y = value, fill=Version)) +
  geom_bar(position="dodge", stat = "identity", width=.5) +
  scale_y_continuous(expand = c(0,0), limits = c(0,290.4)) +
  geom_hline(yintercept=264) +
  annotate("text", x = 1.5, y = 275, label = "Hardware Bandwidth Limit", size = 5) +
  scale_x_discrete(expand=c(0,0.5)) +
  scale_fill_manual(values=c("#de2d26", "#a50f15")) +
  theme + labs(x = "", y = "")

intel <- data[data$Platform == "Intel",]
intel$Version <- factor(intel$Version, levels = c("Generated", "MKL"))
intelPlot <- ggplot(intel, aes(x = Version, y = value, fill=Version)) +
  geom_bar(position="dodge", stat = "identity", width=.5) +
  scale_y_continuous(expand = c(0,0), limits = c(0,28.25)) +
  geom_hline(yintercept=25.6) +
  annotate("text", x = 1.5, y = 26.5, label = "Hardware Bandwidth Limit", size = 5.25) +
  scale_x_discrete(expand=c(0,0.5)) +
  scale_fill_manual(values=c("#de2d26", "#a50f15")) +
  theme + labs(x = "", y = "")

# save plot to file
pdf("reduce_automatic_runtime.pdf", width = 10, height = 5.5)

multiplot(nvidiaPlot, amdPlot, intelPlot, cols=3)
dev.off()
multiplot(nvidiaPlot, amdPlot, intelPlot, cols=3)
