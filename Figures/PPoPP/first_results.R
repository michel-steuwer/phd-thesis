# $Id: first_results.R 308 2014-02-24 15:06:49Z cfensch@INF.ED.AC.UK $

source("plots/libs/newlegend.R")

filename="plots/first_results.pdf"

M_bw   <- (as.matrix(read.csv("plots/first_results.csv",row.names=1, sep=";")))

pdf(filename,
    paper="special", height=2.1, width=6.5, pointsize=10)

layout(matrix(c(1,2), 1, 2, byrow=TRUE))

par(mar=c(2.9,3.5,0.4,0.1))
x.abscis <- barplot(t(M_bw[,1:2]),
	col=c("green", "darkgreen"),
	space=c(0, 0.5),
        ylim=c(0, 150),
        axisname=FALSE,
	las=2,
        beside=TRUE,
#        angle=c(45,90,130,180),
#        density=c(30,NA,20,NA),
        plot=TRUE)
box()
abline(h=c(25,50,75,100,125,150,175), col="lightgray", lty="dashed")

barplot(t(M_bw[,1:2]),
	col=c("green", "darkgreen"),
	space=c(0, 0.5),
        axisname=FALSE,
	las=2,
        beside=TRUE,
        add=TRUE)

labels = c("NV1", "NV2", "NV3", "NV4", "NV5", "NV6", "NV7", "AMD")

for (i in 0:8) {
  text(1.5 + (i * 2.5), -20, labels[i+1], xpd=NA, cex=0.9, srt = 0,
       adj=c(0.5, 0))
}

mtext("Bandwidth (GB/s)", side=2, line=2.4, cex=1.00)
text(1, 120, "GTX 480", cex=2, adj=c(0, 0))

x.abscis <- barplot(t(M_bw[,3:4]),
	col=c("red", "darkred"),
	space=c(0, 0.5),
        ylim=c(0, 150),
        axisname=FALSE,
	las=2,
        beside=TRUE,
#        angle=c(45,90,130,180),
#        density=c(30,NA,20,NA),
        plot=TRUE)
box()
abline(h=c(25,50,75,100,125), col="lightgray", lty="dashed")

barplot(t(M_bw[,3:4]),
	col=c("red", "darkred"),
	space=c(0, 0.5),
        axisname=FALSE,
	las=2,
        beside=TRUE,
        add=TRUE)

for (i in 0:8) {
  text(1.5 + (i * 2.5), -20, labels[i+1], xpd=NA, cex=0.9, srt = 0,
       adj=c(0.5, 0))
}

mtext("Bandwidth (GB/s)", side=2, line=2.4, cex=1.00)
text(1, 120, "HD 7970", cex=2, adj=c(0, 0))



par(xpd=NA)
legend(-10,-10, bg="white", horiz=TRUE,
       legend = c("Ref", "Our"), 
       fill = c("red", "darkred"),
       cex=1.25,
       bty="n")
legend2(-10,-10, bg="white", horiz=TRUE,
       legend = c("Ref", "Our"), 
       fill = c("green", "darkgreen"),
       cex=1.25,
       bty="n")

dev.off()

embedFonts(filename, format="pdfwrite",
           options="-dPDFSETTINGS=/prepress -dEmbedAllFonts=true")
