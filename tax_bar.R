#!/bin/Rscript

args=commandArgs(T)
file=args[1]
out=args[2]

library(RColorBrewer)
data<-read.table(file,header=T, com='', sep="\t")
da.des <- data[,1]
da.num <- data[,2:length(data[1,])]
da.num<-data.matrix(da.num)
tiff(out,width = 1800, height = 1800,compression="lzw",res=300)
mat <- matrix(c(1,2), nrow=1,byrow=TRUE)
layout(mat,widths=c(3,2))
par(mar=c(5, 3, 3, 1))
bp=barplot(da.num,col=brewer.pal(12,"Set3"),ylim=c(0,100),cex.name=1,beside=FALSE,xaxt="n")
Da<-read.table(file,header=F, com='', sep="\t")
Da<-Da[,-1]
lab <- as.character(as.matrix(Da[1,]))
text(bp,par("usr")[3]-0.1,srt=60,adj=1,labels=lab,xpd=T,cex=0.6)
mtext("Relative Abundance",side=2,cex=1,line=2)
mtext("Sample Name",side=1,cex=1,line=3)
plot.new()
legend("left",paste(da.des,sep=""),pch=15,col=brewer.pal(12,"Set3"),cex=0.6,bty="n",inset=-0.05,xpd=T)
dev.off()
