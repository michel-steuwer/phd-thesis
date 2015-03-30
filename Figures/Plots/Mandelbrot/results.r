require('ggplot2')
require('grid')


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



# row.names = NULL forces numbering of the lines and, thus, preserves the order
data <- read.csv("results.csv", sep=";", comment.char="#", header=TRUE, row.names=NULL)

#rownumbers <- as.integer(row.names(performance))

# ====Default settins====
theme <- theme_bw() +
  theme(text = element_text(size = 18),
        axis.title = element_text(size = rel(1.125), vjust = 1),
        #axis.text.x = element_text(angle = 45, vjust = 0.7),
        panel.border = element_rect(linetype = "solid", colour = "black", size = 1.5),
        plot.margin = unit(c(2,1.2,0,1), 'cm'),
        legend.position="top",
        strip.background = element_rect(colour = "black", fill = "white", size = 1.5))


lines <- data[data$Type == "   lines",]
labs <- labs(x = "", y = "Lines of Code")
# create plot
lPlot <- ggplot(na.omit(lines), aes(x=Version, y=value, fill=Kind)) +
  geom_bar(color="black", width=.5, stat = "identity") +
  scale_fill_manual(values=c("#fee6ce", "#fdae6b")) + #"#e6550d", 
  scale_x_discrete() + theme + labs


#scale_color_manual(values=c("#fdcc8a", "#fc8d59", "#d7301f"))
runtime <- data[data$Type == "   runtime",]
labs <- labs(x = "", y = "Runtime in Seconds")
# create plot
rPlot <- ggplot(na.omit(runtime), aes(x=Version, y=value, fill=Version)) +
  geom_bar(color="black", width=.5, stat = "identity") +
  scale_fill_manual(values=c("#fc8d59", "#d7301f")) +
  scale_y_continuous(limits=c(0,30)) +
  scale_x_discrete() + theme + theme(plot.margin = unit(c(4,1.2,0,1), 'cm'),
                                     legend.position="none") + labs

pdf("mandelbrot.pdf", width = 8, height = 5)

multiplot(lPlot, rPlot, cols=2)
dev.off()
multiplot(lPlot, rPlot, cols=2)
