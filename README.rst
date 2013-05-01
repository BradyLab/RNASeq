Pipelines for RNASeq analysis
=============================

:Author: Gina Turco (`gturco <https://github.com/gturco>`_)
:Email: gturco88@gmail.com
:License: MIT
.. contents ::

Description
===========

Contains a general pipeline for running RNASeq analysis. This involves converting a sequence read archive file (sra) to a fastaq file. The Fastq file is then aligned to a reference genome and count data is obtained. Last but not least, comparisons between different groups of count data can be made.  For example differential expression between RNAseq read counts mapped to genes of knockout and wild type can be compared.

Pipelines were developed in the `Brady Lab <http://www-plb.ucdavis.edu/labs/brady/>`_ at UC Davis

RNAseq analysis outline provided by Oshlack et al. Genome Biology 2010 11:220   doi:10.1186/gb-2010-11-12-220


.. image:: http://genomebiology.com/content/figures/gb-2010-11-12-220-1-l.jpg
Oshlack et al. Genome Biology 2010 11:220   doi:10.1186/gb-2010-11-12-220

Installation
============

  - Download the most recent code here::
          
        git clone https://github.com/BradyLab/RNASeq

**Required Dependencies**

  - Dependencies were installed onto iplant AMI "RNASeq Analysis v1"and are available through `atmosphere <https://atmo.iplantcollaborative.org/application/>`_
  - Requires bowtie, tophat, samtools, pysam, htseq, edgeR, python2.7
      - Read `INSTALL file for instructions`

Obtaining an Alignment file
============================

If files are obtain from NCBI then the .sra file first needs to be converted to a fastq file::
  
  fastq-dump SRA_file_name

**Input**: SRA, This is an NCBI specific file format used because of its ability to compress read sequence information. This is often the output of many illumina sequencing pipelines.
**Output**: Fastq, These are similar to Fatsta files and contain a header, associated genomic sequence and a quality score for the sequence. This is often encoded in binary and needs to be read by quality control algorithms.

**Build Bowtie Index**

First the small sequence reads need to be aligned back to a reference genome. Reference genome: Model organism you are using, sequence containing coding sequence only, microRNA only or entire genome. BOWTIE excels both in speed and memory efficiency for aligning short sequence reads back to a long reference sequence. In order to obtain this efficiency the reference genome must first be indexed. This creates a database of keys (in this case they would be cds sequences) for each record and positions them into a memory efficient tree::
  
  bowtie-build reference_genome name_for_refrence_genome

**Input**: reference genome (ie TAIR10 cds file)
**Output**: Index files for reference genome

**Bowtie**

Bowtie is then ran against a sample library , some of the important parameters here are 3 prime or 5 prime trimming which allows you to trim aligned reads if there is a barcode associated with them or the quality is not good. -m 1 --best --strata is also important and used to confirm that if more than one read maps to the same region of the reference genome then only the best read is used where -m specifics the number of unique reads allowed.

**Input**: Common name used to index files (should be located in same directory as command), fastq file of your short sequence reads
**Output**: Bam file (this is your sequence alignment map in binary form)


**SAM TOOLS**

While the binary form of the sequence alignment file is more memory efficient converting to a SAM (sequence alignment map) is more human readable and easier to work with. Thus, the BAM file obtained from BOWTIE needs to be converted to a SAM file for obtaining count data information.

**Get Count Data**

This is a perl script that converts the aligned read information from the sam file to readable count data information

**Input**: SAM File
**Output**: Count data for samples

This count data can then be used to identify differentially expressed genes using the EdgeR script

EdgeR
======

**Input**: Count data
**Output**: Count data with FDR and adjusted P-value

First DEList object is created
This requires that groups are assigned such as control and knockout

**1) Compute effective library sizes using TMM normalization:**

In order to fit the data to the model we must first normalize the data. Here normalization acts to make count data from different samples comparable. Therefore normalization tries to compensate for cases where the same gene has be sequenced at different depths.
It thus attempts to fix cases when a small number of genes are highly expressed in one sample but not in the other.

- normalizes by scaling the library by sizes that minimize fold change.
- This is based on the hypothesis that most genes are not differentially expressed



**2) The common dispersion estimates the overall BCV of the dataset, averaged over all genes**

This estimates the negative binomial variance globally (allowing us to use these models on a small number of replicates). Dispersion refers to the relationship between the variance and the mean.


**3) Compute exact genewise tests for differential expression between androgen and control treatments**

Developed an exact test for differential expression appropriate for the negative binomially distributed counts. 
edgeR uses the quantile-adjusted conditional maximum likelihood (qCML) method for ex-
periments with single factor.

-The qCML method calculates the likelihood by conditioning on the total counts for each
tag, and uses pseudo counts after adjusting for library sizes.

-Adjust method is FDR false discovery rate






