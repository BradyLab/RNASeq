data_path= #change to some path where your data is stored
           ##need full data path

WT= #header name of WT files
KO= #header name of KO files
index= # name of index file

##################################################
############## Convert sra to fastq ##############
##################################################

fastq-dump ${data_path}/${WT}.sra
fastq-dump ${data_path}/${KO}.sra

WT_path=${data_path}/${WT}
KO_path=${data_path}/${KO}


#################################################
############### Quality Control #################
#################################################

#Before
#TODO find out why can only do from this dir
./FastQC/fastqc ${WT_path}.fastq
./FastQC/fastqc ${KO_path}.fastq

#Trim and QC
trimReads -q 20 -m 20 -f ${data_path}/adapters.fasta ${WT_path}.fastq
trimReads -q 20 -m 20 -f ${data_path}/adapters.fasta ${KO_path}.fastq

#After
./FastQC/fastqc ${WT_path}.trimmed.fastq
./FastQC/fastqc ${KO_path}.trimmed.fastq


#################################################
################### BWA #########################
#################################################

python aln_bwa.py -n ${WT_path}.trimmed -i ${data_path}/${index}
python aln_bwa.py -n ${KO_path}.trimmed -i ${data_path}/${index}


#TODO add code for removing dups
#################################################
################# Get Counts ####################
#################################################

#perl  getCounts.pl ${WT_path}_mapped_reads.sam
#perl  getCounts.pl ${KO_path}_mapped_reads.sam
#TODO need to use this method since no mapping to gff?
htseq-count -i gene_id -t exon -s no ${WT_path}.sam annotationFile.modified.gtf
htseq-count -i gene_id -t exon -s no ${KO_path}.sam annotationFile.modified.gtf

#################################################
############## Gene enrichment ##################
#################################################


R CMD BATCH EdgeR_analysis.R

#TODO
#get args for EdgeR
#write to table files
#kcounts inuput count file
#groups group <- factor(c("V","V","NV","V","NV","NV"))


