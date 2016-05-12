#!/bin/Rscript

args=commandArgs(T)
file=args[1]
out=args[2]

library(VennDiagram)
data<-read.table(file,header=T,row.names=1,check.names=F)

data = as.matrix(data)
sample_list=colnames(data)

tiff(out)
input <- list(which(data[,1]!=0))
for(i in 2:length(data[1,])){
	input <- append(input,list(which(data[,i]!=0)))
}
names(input)=sample_list
venn.diagram(input,fill=rainbow(length(input)),out,width = 1800, height = 1800,compression="lzw",resolution=300,cex=0.8,cat.cex=0.8,cat.col="blue",margin=0.1)
dev.off()
