# $Id: application_results_amd.R 308 2014-02-24 15:06:49Z cfensch@INF.ED.AC.UK $

source("plots/libs/newlegend.R")

filename="plots/application_results_amd.pdf"

M   <- (as.matrix(read.csv("plots/application_results.csv",row.names=1, sep=";",comment.char="#")))

pdf(filename,
    paper="special", height=2.1, width=3, pointsize=10)

par(mar=c(1.5,3.1,1.5,0.1))
col=c("#FEEDDE", "#A63603")
linewd <- 0.5
par(lwd=linewd)

M_amd <- M[1:10,4:5]
clBlas <- M_amd[,1]
M_speedup <- clBlas / M_amd
M_speedup[is.infinite(M_speedup) == T] = NA

M_speedup_onlybs <- M_speedup
M_speedup_onlybs[1:9,] = NA

x.abscis <- barplot(t(M_speedup),
	col=col,
        ylim=c(0, 4),
        xlim=c(1,32),
        axisname=FALSE,
        axes=FALSE,
        beside=TRUE,
        plot=TRUE,
        xpd=FALSE)

axis(2, cex.axis=0.6, las=2, lwd=0, lwd.ticks=linewd, line=-0.25)
abline(h=seq(0.5,3.5,0.5), col="white")
abline(h=seq(0.5,3.5,0.5), col="lightgray", lty="dashed")

barplot(t(M_speedup),
	col=col,
        axisname=FALSE,
        axes=FALSE,
        beside=TRUE,
        add=TRUE,
        xpd=FALSE)
 
col=c("#fd8d3c", "#A63603")

barplot(t(M_speedup_onlybs),
	col=col,
        axisname=FALSE,
        axes=FALSE,
        beside=TRUE,
        add=TRUE,
        xpd=FALSE)

# overlay the hash lines on top of BlackScholes
barplot(t(M_speedup_onlybs),
	col=c("black",col[3]),
        density = c(35, 0),
        angle = c(45, NA),  
        axisname=FALSE,
        axes=FALSE,
        beside=TRUE,
        add=TRUE)

# hack to deal with huge speedups
text(20.5, 4.03, round(M_speedup[7,2],1), xpd=NA, cex=0.6, adj=c(0.5,0))

box()

for (i in 0:nrow(M_amd)) {
  text(2.0 + (i * 3.0), -0.1, right_part(rownames(M)[i+1]), xpd=NA, cex=0.5,
       adj=c(0.5, 1))
}

for (i in seq(0,nrow(M_amd),2)) {
  text(3.5 + (i * 3.0), -0.3, left_part(rownames(M)[i+1]), xpd=NA, cex=0.6,
       adj=c(0.5, 1), font=2)
}

text(29, -0.3, "BlackScholes", xpd=NA, cex=0.6, adj=c(0.5, 1), font=2)

#for (i in 0:nrow(M_amd)) {
#  text(2.0 + (i * 3.0), -0.1, rownames(M)[i+1], xpd=NA, cex=0.6, srt = 45,
#       adj=c(1, 0))
#}

mtext("Speedup", side=2, line=2.4, cex=0.70)

col=c("#FEEDDE", "#fd8d3c","#A63603")

par(xpd=NA)
legend("top", inset=c(0,-0.20),
       bg=NA, horiz=TRUE,
       legend = c("clBLAS", "Native", "Generated"), 
       fill = col,
       cex=0.70,
       text.width=c(4,4,2),
       bty="n")
legend("top", inset=c(0,-0.20),
       bg=NA, horiz=TRUE,
       legend = c("", "", ""), 
       fill = "black",
       density = c(0, 35, 0),
       angle = c(NA, 45, NA),  
       cex=0.7,
       text.width=c(4,4,2),
       bty="n")

dev.off()

embedFonts(filename, format="pdfwrite",
           options="-dPDFSETTINGS=/prepress -dEmbedAllFonts=true")
