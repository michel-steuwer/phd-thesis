
filename="reduce_amd.pdf"

M_bw <- (as.matrix(read.csv("reduce.csv",row.names=1, sep=";",comment.char="#")))

pdf(filename, paper="special", height=1.6, width=2.5, pointsize=10)

par(mar=c(2.2,3.0,0.5,0.5))
#col=c("#EDF8E9", "#74C476", "#006D2C")
col=c("#de2d26")
linewd <- 0.5
par(lwd=linewd)

x.abscis <- barplot(t(M_bw[,2]),
                    col=col,
                    space=c(0, 0.5),
                    ylim=c(0, 300),
                    axisname=FALSE,
                    axes=FALSE,
                    beside=TRUE,
                    plot=TRUE)
axis(2, cex.axis=0.6, las=2, lwd=0, lwd.ticks=linewd, line=-0.25)

box()

topbw = 264
abline(h=c(topbw), col="black", lty="solid", lwd=1)
text(1,topbw+5, "Hardware Bandwidth Limit", col="black", adj=c(0, 0), cex=0.6)

for (i in 0:(nrow(M_bw)-2)) {
  text(1.25 + (i * 1.5), -15, rownames(M_bw)[i+1], xpd=NA, cex=0.6, srt = 45,
       adj=c(1, 0))
}
i <- 7
text(1.25 + (i * 1.5), -15, "clBLAS", xpd=NA, cex=0.6, srt = 45, adj=c(1, 0))

mtext("Bandwidth (GB/s)", side=2, line=2.0, cex=0.70)

dev.off()

embedFonts(filename, format="pdfwrite",
           options="-dPDFSETTINGS=/prepress -dEmbedAllFonts=true")
