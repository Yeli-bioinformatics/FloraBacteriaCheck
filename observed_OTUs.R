#!/bin/Rscript

args=commandArgs(T)
file=args[1]
out=args[2]

library(grDevices)
data<-read.table(file,header=F)
data<-t(data)
tiff(out,width = 1800, height = 1500,compression="lzw",res=300)
par(mar=c(5,5,3,10))
data = as.matrix(data)
da=data[-1,]
x<-da[,1]
data=data[,-1]
sample_list=as.character(data[1,])
data=data[-1,]

ramp <- colorRamp(c("red", "orange","yellow","green","blue","darkmagenta"));
color<-rgb( ramp(seq(0, 1, length = length(data[1,]))), max = 255)
pch<-16
lty<-1

#y<-data[length(data[,1]),]
#y<-y[-which(is.na(y))]
#y<-na.omit(y)
#y<-as.numeric(y)
y=max(as.numeric(na.omit(data)))
plot(x,data[,1],type="l",ylim=c(0,max(y)*1.1),xlab="Sequences Per Sample",ylab="Observed OTUs",col=color[1])
for(i in 2:length(data[1,]))
{
pch<-append(pch,16)
lty<-append(lty,1)
lines(x, data[,i],type="l", col=color[i])
}
legend("right",sample_list,pch=pch,inset=-0.5,lty=lty,col=color,ncol=1,xpd=T,box.col="white")
