# Comparative Analysis of De Novo Assembly Algorithms
This repository contains the documentation for the INFO B536 Computational Methods for Biomedical Informatis Final Project.

## Overview
De novo assembly is like solving a jigsaw puzzle without a picture guide. During the experimental procedure, DNA or RNA sequences are broken into smaller fragments to make them more manageable for sequencing. These fragments, or reads, are subsequently sequenced and reassembled to form a complete genome. This process is completed by using algorithms to piece together the reads, forming what are called “contigs”. The contigs, along with any existing gaps, are then organized into a scaffold, which provides a more continuous representation of a portion of the genome.

Constructing a genome without the aid of a reference genome is a computationally challenging task, particularly in the realm of metagenomic research. Currently, there are three widely used de novo assembly algorithms to address this challenge: De Bruijn Algorithms, the Greedy Algorithm, and Overlap Layout Consensus. In this paper, we will be conducting a comparative analysis to assess the performance of these three algorithms in building the genome.

## Data Retrieval
Short reads of Escherichia coli (E. coli) are employed for analysis and comparison in this study since E. coli serves as an appropriate organism given its genetic simplicity and the availability of a fully known and sequenced genome. The E. coli dataset was sourced from NCBI SRA under the accession number [SRX17891028](https://www.ncbi.nlm.nih.gov/sra/SRX17891028) and comprises approximately 2 million reads. The reads were generated using the Illumina NovaSeq 6000 sequencing platform.

Additionally, a second dataset is employed in the study. This dataset consists of a genome assembly of E. Coli, also obtained from NCBI under the accession [PRJNA225](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000005845.2/). This will serve as a reference genome for validation purposes.

## Assembler Algorithms
### De Bruijn Graphs: Velvet
The De Bruijn Algorithm is a graphical method for generating cyclic sequences that encompasses all possible k-length combinations of symbols exactly once [2]. This algorithm forms the basis for constructing De Bruijn sequences, enabling the traversal of the graph to extract a sequence that efficiently encapsulates all possible combinations. 

Velvet, a computational tool designed to perform de novo genome assembly from short reads, leverages the principles of de Bruijn graphs. It undergoes two primary steps. Initially, reads are broken up into k-mers, which are stored in a hash table. Subsequently, Velvet constructs a de Bruijn graph based on these k-mers. Since the resulting de Bruijn graph is complex, Velvet employs algorithms to simplify it by removing erroneous connections, resulting in a more refined representation [3]. Using this refined de Bruijn graph as a foundation, Velvet extracts contigs, each representing a distinct segment of the genome, ultimately piecing them together to create a draft genome assembly. 

### Overlap Layout Consensus (OLC): Canu
The OLC approach to de novo assembly algorithms starts by finding and building overlap graphs for the input reads, then bundles parts of the overlap graphs into contigs. From there, the algorithm picks the most likely nucleotide sequence for each contig [7].

Canu is an assembly tool that is specifically designed for high-noise single molecule sequencing [8], which includes long read sequencing like PacBio or Nanopore. The algorithm begins with the correction of errors in the raw sequencing data to enhance accuracy. Subsequently, Canu detects overlaps between sequencing reads, constructs unitigs representing continuous genomic segments, and employs the OLC approach to assemble these unitigs into longer contigs. The algorithm iteratively refines the assembly through polishing steps, where reads are aligned to contigs for further accuracy improvements. 

### Greedy Algorithm: SSAKE
The greedy algorithm operates by initially identifying the two most favorable overlaps between two reads. Afterwards, the greedy algorithm can be used to extend the overlaps. It achieves this by iteratively adding reads that align well with the current assembly, favoring the reads that provide the most confident and longest overlap with the current contig.

SSAKE (String Graph-based Sequence Assembly of K-mers) is a de novo genome assembly tool that employs the greedy algorithm. It operates by iterating through the short sequence reads, which are initially stored in a hash table. It then employs a greedy approach by progressively searching through a prefix tree data structure to identify potential extension candidates. It does so by prioritizing sequence reads by coverage, sorting them in descending order of occurrence to minimize extension errors [8]. This method allows for the reconstruction of genomic sequences by continually adding k-mers based on their overlap with existing sequences, ultimately producing a more comprehensive and accurate genome assembly.

## Experimental Design
Raw FASTQ files underwent preprocessing, which involved adapter trimming and the removal of low-quality reads before assembly. Roughly about 5,000 reads were removed during this process. The aim of this action was to guarantee that the assembly results are not compromised by erroneous data, ensuring a higher quality final assembly outcome.

Subsequently, the preprocessed reads underwent de novo assembly using Velvet, Canu, and SSAKE. The three assemblers were executed with the recommended parameters and were run on various kmer lengths. 

<p align="center">
  <img width="793" alt="workflow" src="https://github.com/ssomalra/INFO-B536-Computational-Methods-for-Biomedical-Informatics/assets/116883221/52f3e414-3e45-49e3-9a44-59b6fab7f108">
  
  <b>Figure 1. Workflow for the comparative analysis of de novo assembly tools.</b>
</p>

The effectiveness of the three assembly algorithms was evaluated through a comprehensive assessment that encompasses a range of assembly metrics, performance metrics, and accuracy validation. The assembly metrics include fundamental parameters such as the N50 score, the total count of contigs produced, the length of the longest contig generated, and the overall length of the assembled genome. Performance metrics are essential as well, involving the measurement of runtime and memory consumption to gauge the computational efficiency of each algorithm.

To validate the results obtained from the three algorithms, the assembled genome with the highest N50 scores was compared against a known E. coli reference genome. To determine the accuracy of the alignment, the following equation was employed:
<p align="center">
  <img width="400" alt="Screen Shot 2023-12-19 at 10 39 32 AM" src="https://github.com/ssomalra/INFO-B536-Computational-Methods-for-Biomedical-Informatics/assets/116883221/f1ded6cf-1b49-4cc2-a1a9-fa69244aa117">
</p>

This evaluation approach provides a comprehensive assessment of de novo assembly algorithms, ensuring that the final genome is both high-quality and reliable.

## Results
Figure 2A visually depicts the impact of kmer length on the N50 score for both Velvet and SSAKE. The results from this analysis suggest that the performance of Velvet is notably enhanced when employing longer k-mer sizes, surpassing that of SSAKE. Specifically, the N50 score for Velvet attains its highest at a k-mer length of 97, while SSAKE achieves its peak at a k-mer length of 50. An in-depth examination of the data reveals an intriguing trend: Velvet consistently generates assemblies characterized by numerous short contigs when shorter k-mer sizes are used in the assembly process, in stark contrast to SSAKE (Figure 2B,C).

This makes sense, as shorter k-mer sizes can present challenges for De Bruijn graph assemblers. Specifically, using shorter k-mers can increase graph complexity by increasing the number of nodes, intensify ambiguity due to a higher likelihood of encountering repetitive regions, and result in a loss of specificity by merging unrelated sequences.

<p align="center">
  <img width="793" alt="assembly_stats" src="https://github.com/ssomalra/INFO-B536-Computational-Methods-for-Biomedical-Informatics/assets/116883221/ca7340a6-efc7-4816-9048-0b061858988d">

  <b>Figure 2. Comparison of assembly statistics.</b> A. Line plots comparing N50 values by k-mer size for Velvet and SSAKE. B,C. Tables summarizing the assembly statistics for Velvet and SSAKE. The rows highlighted in yellow indicate the k-mer that yields the assembly with the highest N50 score. 
</p>

In terms of computation efficiency, Velvet outperformed SSAKE in several aspects. Velvet used less system resources, requiring approximately 4.7 GB of RAM, whereas SSAKE consumed about 7.7 GB. Additionally, the entire process, encompassing both the creation of the hash index and the generation of the assembly, took Velvet a total of 2 minutes and 51 seconds. In contrast, SSAKE’s runtime was noticeably slower, taking approximately 12 minutes and 32 seconds to complete the same tasks. The relatively slower performance of SSAKE in comparison to Velvet can be explained by its utilization of the greedy algorithm. The inherent characteristic of greedy algorithms, requiring exploration of an extensive search space to identify an optimal solution, could contribute to the observed delay in SSAKE’s execution.  

Furthermore, to validate the accuracy of the assembled genomes that achieved the highest N50 score through de novo algorithms, the contigs were compared to a known E. coli reference genome using BLAST. Surprisingly, SSAKE outperformed Velvet significantly, exhibiting alignment rates of approximately 90% and 36%, respectively. This underscores SSAKE superior performance in constructing an accurate genome. Various factors could contribute to the significant difference in alignment rates between Velvet and SSAKE. For instance, the nature of the sequencing data, such as read length, coverage, or presence of repetitive elements, may favor SSAKE’s algorithm over Velvet’s. Moreover, SSAKE’s approach to error correction might have been more robust to the specific error profile in the data. This prompts the need for further research to determine the underlying reasons for this observed difference.

Ultimately, our results from the OLC approach were inconclusive, a possibility recognized early in the formulation of the project approach. Despite following Canu tutorials, we were unable to receive results due to the assembly tool. Notably, Canu, while acknowledging the high quality of short reads, deems them unsuitable due to their insufficient length for accurate alignment. The tool instead utilizes reads from other repeat instances for correction, leading to potential inaccuracies in the correction process [9]. While intriguing in its capacity to identify short reads despite specified input arguments, this limitation hindered our ability to compare Canu’s outputs with those generated by other assembly methods.


