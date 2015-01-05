# $Id: application_results_vs_BEST_intel.R 358 2014-02-25 11:28:20Z v1msteuw@INF.ED.AC.UK $

source("plots/libs/newlegend.R")


filename="plots/application_results_vs_BEST_intel.pdf"

M   <- (as.matrix(read.csv("plots/application_results.csv",row.names=1, sep=";",comment.char="#")))

pdf(filename,
    paper="special", height=1.6, width=2, pointsize=10)

par(mar=c(1.5,2.2,1.5,0.1))
#col=c("#EFF3FF", "#08519c")
# blue
col=c("#deebf7", "#3182bd")
# red
col=c("#fee0d2", "#de2d26")
linewd <- 0.5
par(lwd=linewd)

M_data <- M[1:8,7:8]
M_base <- M_data[,c(1,1)]
M_speedup <- M_base / M_data
M_speedup[is.infinite(M_speedup) == T] = NA

x.abscis <- barplot(t(M_speedup),
	            col=col,
                    ylim=c(0, 3.2),
                    xlim=c(1, 24),
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

box()

for (i in 0:nrow(M_data)) {
  text(2.0 + (i * 3.0), -0.1, right_part(rownames(M)[i+1]), xpd=NA, cex=0.5,
       adj=c(0.5, 1))
}

for (i in seq(0,nrow(M_data),2)) {
  text(3.5 + (i * 3.0), -0.3, left_part(rownames(M)[i+1]), xpd=NA, cex=0.6,
       adj=c(0.5, 1), font=2)
}

mtext("Speedup over ATLAS", side=2, line=1.15, cex=0.70)

par(xpd=NA)
legend("top", inset=c(0,-0.25),
       bg=NA, horiz=TRUE,
       legend = c("ATLAS", "Generated"), 
       fill = col[c(1,2,2,3)],
       cex=0.70,
       bty="n")

dev.off()

embedFonts(filename, format="pdfwrite",
           options="-dPDFSETTINGS=/prepress -dEmbedAllFonts=true")
