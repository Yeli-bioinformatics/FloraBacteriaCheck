data <- read.table("intestinal_type.xls",sep="\t",header=T)

xlabels <- round(data$Ratio/sum(data$Ratio)*100,2)
xlabels <- paste(xlabels,"%", sep="")
xlabels <- paste(data$Genus,xlabels, sep=" ")

png("intestinal_type.png");
pie(data$Ratio,col=c("green","blue","red","white"),labels=xlabels,cex=1.5)
dev.off()
