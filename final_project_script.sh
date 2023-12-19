#!/bin/bash

## PREPROCESSING
# load fastq file
module load sra-toolkit/3.0.0
prefetch SRR21904868

# quality control - fastqc
module load fastqc
fastqc SRR21904868_1.fastq SRR21904868_2.fastq


# trimming - trimgalore
module load trimgalore
trim_galore --phred33 --fastqc --paired SRR21904868_1.fastq SRR21904868_2.fastq


## DE NOVO ASSEMBLY
# VELVET
module load velvet

# build hash index
velveth output_directory <kmer_size> -short -separate -fastq SRR21904868_1_val_1.fq SRR21904868_2_val_2.fq

# run assembly
velvetg output_directory


# CANU
Canu -p ecoli -d ecoli genomeSize=4.8m -pacbio SRR21904868.fastq


# SSAKE
# prepare input file
# convert fastq > fasta
awk 'NR%4==1{print ">"$1; next} NR%4==2{print}' SRR21904868_1_val_1.fq > SRR21904868_1.fasta
awk 'NR%4==1{print ">"$1; next} NR%4==2{print}' SRR21904868_2_val_2.fq > SRR21904868_2.fasta

# merge forward and reverse reads in one file
paste -d ':' forward.fasta reverse.fasta > merged.fasta

# run SSAKE
./ssake/SSAKE -f modified4.fasta -p 1 -w 5 -m <kmer_size> -b assembly<kmer_size>


# TO GET PERFORMANCE METRICS
/usr/bin/time -v <insert_assembler_command>


## VALIDATION WITH REFERENCE GENOME
# download E. coli genome: https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000005845.2/ 

module load blast
blastn -query <contigs.fa> -subject GCF_000005845.2_ASM584v2_genomic.fna -out validation.out -outfmt 6

# to extract total number of queries
sort -u -k1,1 validation.out | wc -l

