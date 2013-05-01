##### RNASeq  #####
###################

index_


####### Sample data #########
############################

# Find GEO accession number
# http://www.ncbi.nlm.nih.gov/geo/
## GSE35315
## Oh Wang Paper...
#wget ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByExp/sra/SRX%2FSRX140%2FSRX140101/SRR477075/SRR477075.sra
#wget ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByExp/sra/SRX%2FSRX140%2FSRX140102/SRR477076/SRR477076.sra

############################


## QC
## NEED TO LOOK INTO STILL
#https://github.com/tanghaibao/trimReads




## Take .sra file and convert to .fastq file ######
###### http://azaleasays.com/2011/09/09/convert-sra-format-to-fastq/
# install ....
	##wget http://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.3.2/sratoolkit.2.3.2-centos_linux64.tar.gz
	#tar -xvzf sratoolkit.2.3.2-centos_linux64
	#sudo cp bin/fastq-dump /usr/local/bin/
echo converting sra to fastq

fastq-dump  /home/gturco/mydata/SRR/oh_wang/SRR477075.sra
fastq-dump /home/gturco/mydata/SRR/oh_wang/SRR477076.sra


## Build Bowtie Index
echo building bowtie index

### WEGET TO A DIFFRENT NAME
## cDNA
#wget ftp://ftp.arabidopsis.org/Sequences/blast_datasets/TAIR10_blastsets/TAIR10_cdna_20110103_representative_gene_model_updated
bowtie-build TAIR10_cdna_20110103 TAIR10_cdna

## Run Bowtie
echo running Bowtie
bowtie TAIR10_cdna SRR477075.fastq  -v 2 -5 4 -3 0 -m 1 --best --strata --sam mapped_reads.sam

## Get count data
perl  getCounts.pl SRR477075_mapped_reads.sam
perl  getCounts.pl SRR477076_mapped_reads.sam
