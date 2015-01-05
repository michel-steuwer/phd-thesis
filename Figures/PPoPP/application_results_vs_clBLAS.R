# $Id: application_results_vs_clBLAS.R 385 2014-02-25 20:39:14Z v1msteuw@INF.ED.AC.UK $

source("plots/libs/newlegend.R")


filename="plots/application_results_vs_clBLAS.pdf"

M   <- (as.matrix(read.csv("plots/application_results.csv",row.names=1, sep=";",comment.char="#")))

pdf(filename,
    paper="special", height=1.6, width=3, pointsize=10)

par(mar=c(1.16,2.15,1.5,0.1))
#col=c("#74c476", "#fd8d3c", "#6BAED6")
#col=c("#33a02c", "#ff7f00", "#1f78b4")

# green, red, blue
#col=c("#abdda4", "#d7191c", "#2b83ba")
col=c("#31a354", "#de2d26", "#3182bd")
# red, orange, blue
col=c("#d7191c", "#fdae61", "#2b83ba")
# orange, red, blue
#col=c("#fdae61", "#d7191c", "#2b83ba")


col=c("#ffeda0", "#feb24c", "#f03b20")

# from master thesis: yellow, red, orange
#col=c("#f0b400", "#b30024", "#d84100")

# yellow, red, blue
#col=c("#ffffbf", "#d7191c", "#2c7bb6")

# all gray ...
#col=c("#f0f0f0", "#bdbdbd", "#636363")

# all purple
#col=c("#efedf5", "#bcbddc", "#756bb1")
linewd <- 0.5
par(lwd=linewd)

M_data <- M[1:11,c(3,5,8)]
M_base <- M[1:11,c(1,4,6)]
M_speedup <- M_base/ M_data
M_speedup[is.infinite(M_speedup) == T] = NA

x.abscis <- barplot(t(M_speedup),
	            col=col,
                    ylim=c(0, 4),
                    xlim=c(1, 44),
                    axisname=FALSE,
                    axes=FALSE,
                    beside=TRUE,
                    plot=TRUE,
                    xpd=FALSE)
axis(2, cex.axis=0.6, las=2, lwd=0, lwd.ticks=linewd, line=-0.25)
abline(h=seq(0.5,3.5,0.5), col="white")
abline(h=seq(0.5,3.5,0.5), col="lightgray", lty="dashed")
abline(h=1, col="black", lwd=1.0)


barplot(t(M_speedup),
	col=col,
        axisname=FALSE,
        axes=FALSE,
        beside=TRUE,
        add=TRUE,
        xpd=FALSE)


# hack to deal with huge speedups
text(11.5, 4.10, round(M_speedup[3,3],1), xpd=NA, cex=0.6, adj=c(0.5,0))
text(15.5, 4.10, round(M_speedup[4,3],1), xpd=NA, cex=0.6, adj=c(0.5,0))
text(26.5, 4.10, round(M_speedup[7,2],1), xpd=NA, cex=0.6, adj=c(0.5,0))

box()

for (i in 0:nrow(M_data)) {
  text(2.5 + (i * 4.0), -0.1, right_part(rownames(M)[i+1]), xpd=NA, cex=0.5,
       adj=c(0.5, 1))
}

for (i in seq(0,nrow(M_data),2)) {
  text(4.5 + (i * 4.0), -0.3, left_part(rownames(M)[i+1]), xpd=NA, cex=0.6,
       adj=c(0.5, 1), font=2)
}

text(38, -0.175, "Black", xpd=NA, cex=0.6, adj=c(0.5, 1), font=2)
text(38, -0.425, "Scholes", xpd=NA, cex=0.6, adj=c(0.5, 1), font=2)

text(42.5, -0.3, "MD", xpd=NA, cex=0.6, adj=c(0.5, 1), font=2)

mtext("Speedup", side=2, line=1.15, cex=0.70)

par(xpd=NA)
legend("top", inset=c(0,-0.25),
       bg=NA, horiz=TRUE,
       legend = c("Nvidia GPU", "AMD GPU", "Intel CPU"), 
       fill = col,
       cex=0.70,
#       text.width=c(6,6,4),
       bty="n")


dev.off()

embedFonts(filename, format="pdfwrite",
           options="-dPDFSETTINGS=/prepress -dEmbedAllFonts=true")
