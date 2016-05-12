#!/bin/Rscript

args=commandArgs(T)
file=args[1]

dat=read.table(file,header=T,strip.white=T,sep="\t")
len=length(rownames(dat))
le=len-2
pch <- c(rep(15,len-2))
cols <- c(rep("red",len-2))
pc1<-round(dat[len,2],2)
pc2<-round(dat[len,3],2)
pc3<-round(dat[len,4],2)

tiff("PC1_vs_PC2_plots.tif",width=1800,height=1800,res=300)
plot(dat[c(1:le),2],dat[c(1:le),3],xlab=paste("PC1-Percent variant explained ",pc1,"%",sep=""),
     ylab=paste("PC2-Percent variant explained ",pc2,"%",sep=""),xlim=c(min(dat[c(1:le),2])*1.1,max(dat[c(1:le),2])*1.2),main="PCoA-PC1 vs PC2",col=cols,pch=pch)
na=dat[c(1:le),1]
text(dat[c(1:le),2],dat[c(1:le),3],labels=na,pos=4,cex=0.8)
abline(h=0,v=0)

tiff("PC3_vs_PC2_plots.tif",width=1800,height=1800,res=300)
plot(dat[c(1:le),4],dat[c(1:le),3],xlab=paste("PC3-Percent variant explained ",pc3,"%",sep=""),
     ylab=paste("PC2-Percent variant explained ",pc2,"%",sep=""),xlim=c(min(dat[c(1:le),4])*1.1,max(dat[c(1:le),4])*1.2),main="PCoA-PC3 vs PC2",col=cols,pch=pch)
na=dat[c(1:le),1]
text(dat[c(1:le),4],dat[c(1:le),3],labels=na,pos=4,cex=0.8)
abline(h=0,v=0)

tiff("PC1_vs_PC3_plots.tif",width=1800,height=1800,res=300)
plot(dat[c(1:le),2],dat[c(1:le),4],xlab=paste("PC1-Percent variant explained ",pc1,"%",sep=""),
     ylab=paste("PC3-Percent variant explained ",pc3,"%",sep=""),xlim=c(min(dat[c(1:le),2])*1.1,max(dat[c(1:le),2])*1.2),main="PCoA-PC1 vs PC3",col=cols,pch=pch)
na=dat[c(1:le),1]
text(dat[c(1:le),2],dat[c(1:le),4],labels=na,pos=4,cex=0.8)
abline(h=0,v=0)

dev.off()
