#Geo: http://www.nature.com/ng/journal/v43/n7/full/ng.854.html
#The ChIP-Seq dataset and ATH1 expression array dataset are deposited in Gene Expression Omnibus (GEO) under the accession code GSE25447.
#wget http://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE25447&format=file
#tar -xvf in
#1-kb window size used in the ChIPDiff program

### Get Data

#Get WT Data
wget ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByExp/sra/SRX%2FSRX031%2FSRX031221/SRR072991/SRR072991.sra
fastq-dump /home/gturco/data/find_maize/chip/SRR072991.sra
mv SRR072991.fastq WT.fastq

#Get KO Data
wget ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByExp/sra/SRX%2FSRX031%2FSRX031222/SRR072992/SRR072992.sra
fastq-dump /home/gturco/data/find_maize/chip/SRR072992.sra
mv SRR072992.sra KO.fastq

#### QC
#Data Before
#TODO find out why can only do from this dir
./FastQC/fastqc KO.fastq
./FastQC/fastqc WT.fastq

#trim and QC read
trimReads -q 20 -m 20 -f adapters.fasta KO.fastq
trimReads -q 20 -m 20 -f adapters.fasta WT.fastq

#Data After
./FastQC/fastqc KO.trimmed.fastq
./FastQC/fastqc WT.trimmed.fastq




#### BWA
python aln_bwa.py -n KO -i genome
python aln_bwa.py -n WT -i genome

#TODO add code for removing dups!
#sort and convert sam to bed file
sam2bed < KO.sam > sorted-KO.sam.bed
sam2bed < WT.sam > sorted-WT.sam.bed

vim sorted-KO_head.sam.bed
%s/^/chr

#Run SICER
sh ~/Downloads/SICER_V1.1/SICER/SICER-df-rb.sh sorted-KO_head.sam.bed sorted-WT_head.sam.bed 10000 20000 0.001 0.001 > sicer_out
