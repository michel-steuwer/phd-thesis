# $Id: application_results_vs_BEST_amd.R 576 2014-09-04 10:13:46Z v1msteuw $

source("plots/libs/newlegend.R")

filename="plots/application_results_vs_BEST_amd.pdf"

M   <- (as.matrix(read.csv("plots/application_results.csv",row.names=1, sep=";",comment.char="#")))

pdf(filename,
    paper="special", height=1.4, width=2, pointsize=10)

par(mar=c(1.5,2.2,1.5,0.1))
#col=c("#FEEDDE", "#A63603")
# red
col=c("#fee0d2", "#de2d26")
# orange
col=c("#fee6ce", "#e6550d")
linewd <- 0.5
par(lwd=linewd)

M_amd <- M[1:8,4:5]
M_base <- M_amd[,c(1,1)]
M_speedup <- M_base / M_amd
M_speedup[is.infinite(M_speedup) == T] = NA

x.abscis <- barplot(t(M_speedup),
	col=col,
        ylim=c(0, 2.0),
        xlim=c(1,24),
        axisname=FALSE,
        axes=FALSE,
        beside=TRUE,
        plot=TRUE,
        xpd=FALSE)

axis(2, cex.axis=0.6, las=2, lwd=0, lwd.ticks=linewd, line=-0.25, at=c(0,1,2,3))
abline(h=seq(0.5,3.5,0.5), col="white")
abline(h=seq(0.5,3.5,0.5), col="lightgray", lty="dashed")

barplot(t(M_speedup),
	col=col,
        axisname=FALSE,
        axes=FALSE,
        beside=TRUE,
        add=TRUE,
        xpd=FALSE)
 
# hack to deal with huge speedups
text(20.5, 2.05, round(M_speedup[7,2],1), xpd=NA, cex=0.6, adj=c(0.5,0))
text(23.5, 2.05, round(M_speedup[8,2],1), xpd=NA, cex=0.6, adj=c(0.5,0))

box()

for (i in 0:nrow(M_amd)) {
  text(2.0 + (i * 3.0), -0.1, right_part(rownames(M)[i+1]), xpd=NA, cex=0.5,
       adj=c(0.5, 1))
}

for (i in seq(0,nrow(M_amd),2)) {
  text(3.5 + (i * 3.0), -0.3, left_part(rownames(M)[i+1]), xpd=NA, cex=0.6,
       adj=c(0.5, 1), font=2)
}

#for (i in 0:nrow(M_amd)) {
#  text(2.0 + (i * 3.0), -0.1, rownames(M)[i+1], xpd=NA, cex=0.6, srt = 45,
#       adj=c(1, 0))
#}

mtext("Speedup over clBLAS", side=2, line=1.15, cex=0.70)

par(xpd=NA)
legend("top", inset=c(0,-0.3),
       bg=NA, horiz=TRUE,
       legend = c("clBLAS", "Generated"), 
       fill = col,
       cex=0.70,
#       text.width=c(4,4,2),
       bty="n")

dev.off()

embedFonts(filename, format="pdfwrite",
           options="-dPDFSETTINGS=/prepress -dEmbedAllFonts=true")
