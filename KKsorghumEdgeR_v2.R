### Script to analyse DE genes in vascular and non-vascular samples modified by Gina from Kaisa's orginal (4/4/13) script
### Script to analyse DE genes in vascular and non-vascular samples from Sorghum by Kaisa (4/4/13)
### Modified from edgeRUsersGuide revised 14 Dec 2012, Following the example from section 4.3
### (http://www.bioconductor.org/packages/2.11/bioc/vignettes/edgeR/inst/doc/edgeRUsersGuide.pdf

setwd("~/Rwork")

source("http://bioconductor.org/biocLite.R")
biocLite("edgeR")
library(edgeR)

## write all plots to this file
pdf("~/SorghumDEPlots.pdf")

#Reading in the counts table (this next set assumes you have all the counts in the same table, #with sample names as column name)

xorig <- read.delim("kcounts.txt",row.names="Gene")
x <- xorig[,3:8]
#x[is.na(x)] <- 0
head(x)

#assigning vascular and non-vascular groups and creating DGEList object
group <- factor(c("V","V","NV","V","NV","NV"))
y <- DGEList(counts = x, group=group)

#filtering out lowly expressed tags
#keep <- rowSums(cpm(y)>1) >= 3
#y <- y[keep,]
#dim(y)

#re-compute library sizes
#y$samples$lib.size <- colSums(y$counts)

#Compute effective library sizes using TMM normalization:
y <- calcNormFactors(y)
y$samples

logcount <- log(x+1,2)
boxplot(logcount,notch=TRUE, range=0,col=c(colors()[c(566,131,133,137 )]),
        ylab="log2[counts+1]", xlab="sample", main="Before Raw Counts")

flogcount <- log(x[filteredhits,]+1,2)
boxplot(flogcount,notch=TRUE, range=0,col=c(colors()[c(566,131,133,137 )]),
        ylab="log2[counts+1]", xlab="sample", main="Filtered Raw Counts")

alogcount <- log(cpm(y)+1,2)
boxplot(alogcount,notch=TRUE, range=0,col=c(colors()[c(566,131,133,137 )]),
        ylab="log2[counts+1]", xlab="sample", main="After Raw Counts")

aflogcount <- log(cpm(y)[filteredhits,]+1,2)
boxplot(aflogcount,notch=TRUE, range=0,col=c(colors()[c(566,131,133,137 )]),
        ylab="log2[counts+1]", xlab="sample", main="After Filtered Raw Counts")




#The common dispersion estimates the overall BCV of the dataset, averaged over all genes:
y <- estimateCommonDisp(y, verbose=TRUE)

#Now estimate gene-specifc dispersions:
y <- estimateTagwiseDisp(y)

### filter out hits less than 3 in both V and NV
v = which(cpm(y)[,"NABN"] > 3 & cpm(y)[,"NABO"] > 3 & cpm(y)[,"NABS"] > 3)
nv = which(cpm(y)[,"NABP"] > 3 & cpm(y)[,"NABT"] > 3 & cpm(y)[,"NABU"] > 3)
filteredhits = union(v,nv)

## Make a copy of EdgeR Object filtered
f <- y
f$counts <- y$counts[filteredhits,]
f$pseudo.counts <- y$pseudo.counts[filteredhits,]
f$logCPM <- y$logCPM[filteredhits]
f$tagwise.dispersion <- y$tagwise.dispersion[filteredhits]

#An MDS plots shows distances, in terms of biological coeffcient of variation (BCV), between samples:
plotMDS(y)          ##Vs cluster together, NVs cluster even better!
plotMDS(f)

#Plot the estimated dispersions:
plotBCV(y)
plotBCV(f)
##Compute exact genewise tests for differential expression between androgen and control treatments:
et <- exactTest(y)
fet <- exactTest(f)
top <- topTags(et)
all <- topTags(et, n = nrow(y), adjust.method = "fdr")
#order all counts A-Z
all <- all$table[order(row.names(all$table)),]

#Check the individual cpm values for the top genes:
cpm(y)[rownames(top), ]

#The total number of DE genes at 5% FDR is given by  (-1:up, 0:same, 1:down)
summary(de <- decideTestsDGE(et))
summary(fde <- decideTestsDGE(fet))

#Plot the log-fold-changes, highlighting the DE genes:
detags <- rownames(y)[as.logical(de)]
plotSmear(et, de.tags=detags)
abline(h=c(-1, 1), col="blue")   #(blue line for 2-fold changes)


fdetags <- rownames(f)[as.logical(fde)]
plotSmear(fet, de.tags=fdetags)
abline(h=c(-1, 1), col="blue")   #(blue line for 2-fold changes)


#Write output to pdf and to table
dev.off()


ytable <- cbind(cpm(y),all)
ytable <- ytable[order(ytable$FDR),]
write.table(ytable, "vascular_sorghum_edgeR.txt", sep="\t")
f = ytable[filteredhits,]
write.table(f, "vascular_sorghum_edgeR_filtered.txt", sep="\t")


