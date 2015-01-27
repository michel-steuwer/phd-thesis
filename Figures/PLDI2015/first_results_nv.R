# $Id: first_results_nv.R 308 2014-02-24 15:06:49Z cfensch@INF.ED.AC.UK $

source("plots/libs/newlegend.R")

filename="plots/first_results_nv.pdf"

M_bw   <- (as.matrix(read.csv("plots/first_results.csv",row.names=1, sep=";",comment.char="#")))

pdf(filename,
    paper="special", height=2.1, width=3, pointsize=10)

par(mar=c(2.4,3.5,1.0,0.1))
col=c("#EDF8E9", "#006D2C")
linewd <- 0.5
par(lwd=linewd)

x.abscis <- barplot(t(M_bw[1:4,1:2]),
	col=col,
	space=c(0, 0.5),
        ylim=c(0, 200),
	xlim=c(1, 18),
        axisname=FALSE,
        axes=FALSE,
        beside=TRUE,
        plot=TRUE)
axis(2, cex.axis=0.6, las=2, lwd=0, lwd.ticks=linewd, line=-0.25)
abline(h=seq(25,175,25), col="white")
abline(h=seq(25,175,25), col="lightgray", lty="dashed")

box()

topbw = 177.4
abline(h=c(topbw), col="black", lty="solid", lwd=1)
text(1,topbw+5, "Hardware Bandwidth Limit", col="black", adj=c(0, 0), cex=0.6)


barplot(t(M_bw[1:4,1:2]),
	col=col,
	space=c(0, 0.5),
        axisname=FALSE,
	axes=FALSE,
        lwd=linewd,
        beside=TRUE,
       add=TRUE)

col=c("#74C476", "#006D2C")

barplot(t(M_bw[5:16,1:2]),
	col=col,
	space=c(0.5),
        axisname=FALSE,
	axes=FALSE,
        lwd=linewd,
        beside=FALSE,
        add=TRUE)


for (i in 0:3) {
  text(2.0 + (i * 2.5), -10, rownames(M_bw)[i+1], xpd=NA, cex=0.6, srt = 45,
       adj=c(1, 0))
}

for (i in 12:16) {
  text(-4.5 + (i * 1.5), -10, rownames(M_bw)[i+1], xpd=NA, cex=0.6, srt = 45,
       adj=c(1, 0))
}

mtext("Bandwidth (GB/s)", side=2, line=2.4, cex=0.70)
#text(1, 120, "GTX 480", cex=2, adj=c(0, 0))

col=c("#EDF8E9", "#74C476", "#006D2C")

par(xpd=NA)
legend("top", inset=c(0,-0.15),
       bg="white", horiz=TRUE,
       legend = c("Hand-written", "Libraries", "Generated"), 
       fill = col,
       cex=0.70,
       text.width=c(4,3.5,2),
       bty="n")

# legend("topleft", inset=c(0.05,0.15),
#        bg="white", horiz=FALSE,
#        legend = c("Hand Tuned", "Automatic"), 
#        fill = c("green", "darkgreen"),
#        cex=0.70,
#        bty="y")


dev.off()

embedFonts(filename, format="pdfwrite",
           options="-dPDFSETTINGS=/prepress -dEmbedAllFonts=true")
