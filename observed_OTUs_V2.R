#!/bin/Rscript

args=commandArgs(T)
file=args[1]
out=args[2]

library(grDevices)
data=read.table(file,header=T,row.names=1,check.names=F)
tiff(out,width = 1800, height = 1500,compression="lzw",res=300)
par(mar=c(5,5,3,10))
x=colnames(data)
sample_list=rownames(data)
data=as.matrix(t(data))
ramp <- colorRamp(c("red", "orange","yellow","green","blue","darkmagenta"));
color<-rgb( ramp(seq(0, 1, length = length(data[1,]))), max = 255)
pch<-16
lty<-1
y=max(as.numeric(na.omit(data)))
plot(x,data[,1],type="l",ylim=c(0,max(y)*1.1),xlab="Sequences Per Sample",ylab="Observed OTUs",col=color[1])
for(i in 2:length(data[1,]))
{
pch<-append(pch,16)
lty<-append(lty,1)
lines(x, data[,i],type="l", col=color[i])
}
legend("right",sample_list,pch=pch,inset=-0.5,lty=lty,col=color,ncol=1,xpd=T,box.col="white")
dev.off()
