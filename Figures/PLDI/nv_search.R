# $Id: application_results_nv.R 308 2014-02-24 15:06:49Z cfensch@INF.ED.AC.UK $

source("plots/libs/newlegend.R")

data   <- read.csv("plots/nv_search_sorted.csv",sep=";",comment.char="#",header=TRUE)
numbers <- data$performance
numbers_without_zero <- numbers[which(numbers != 0)]
#numbers_without_zero <- numbers_without_zero / 139.23

filename="plots/nv_search.pdf"
pdf(filename,
    paper="special", height=4, width=6, pointsize=12)

par(mar=c(4,4,1,1)+0.1)

#plot(numbers,
plot(numbers_without_zero,
     type= "p",
     xlab="Number of evaluated expressions",
     ylab="Absolute performance in GB/s",
     cex.lab=1.35,
     cex.axis=1.2
    #,ylim = c(0,1)
     )

pos <- c(8,17,27,35,44,49,52,55,57,69)

rect( -2, -4,pos[1]+.5,150, col = rgb(0.85,0.85,0.85,1/4))
rect(pos[1]+.5, -4,pos[2]+.5,150, col = rgb(0.8,0.8,0.8,1/4))
rect(pos[2]+.5,-4,pos[3]+.5,150, col = rgb(0.75,0.75,0.75,1/4))
rect(pos[3]+.5,-4,pos[4]+.5,150, col = rgb(0.7,0.7,0.7,1/4))
rect(pos[4]+.5,-4,pos[5]+.5,150, col = rgb(0.65,0.65,0.65,1/4))
rect(pos[5]+.5,-4,pos[6]+.5,150, col = rgb(0.6,0.6,0.6,1/4))
rect(pos[6]+.5,-4,pos[7]+.5,150, col = rgb(0.55,0.55,0.55,1/4))
rect(pos[7]+.5,-4,pos[8]+.5,150, col = rgb(0.5,0.5,0.5,1/4))
rect(pos[8]+.5,-4,pos[9]+.5,150, col = rgb(0.45,0.45,0.45,1/4))
rect(pos[9]+.5,-4,pos[10]+10,150, col = rgb(0.4,0.4,0.4,1/4))

pos <- c(1,2,3,4,5,6,7,pos)
lines(pos, numbers_without_zero[pos], col="red", lwd=2)

box()

dev.off()

#embedFonts(filename, format="pdfwrite",
#           options="-dPDFSETTINGS=/prepress -dEmbedAllFonts=true")
