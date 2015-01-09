Procedural Materials and Methods: (See note above)

***All scripts and code can be found at https://github.umn.edu/klang/RNASeq***

GALAXY: FASTQ GROOMER and FASTQC
1.	MSI usually directly loads these into Galaxy so no manual upload is needed.  These should be in fastq format.

2.	Under the NGS quality toolbox select fastq groomer and run it on each dataset.  Fastq Groomer changes the quality score format for use with Bowtie.


3.	Run FastQC (also in NGS quality toolbox) on each dataset.

4.	Record the quality across each base in the read.  Take not of which position at the 3’ end that the mean quality score falls off.  This is where you want to trim.

NGS MAPPING: Bowtie for Illumina
1.	Bowtie for Illumina requires 2 things – reads files (fastq) and a reference sequence (fasta).  It may be necessary to upload 2 reads files if a paired-end experiment was done.  

2.	At the top, select the reference sequence. To select an uploaded fasta sequence  choose “select from history”.

3.	Next select single-end or paired-end library.

4.	Next select reads files (fastq format).

5.	Next select “Full parameter list”.


6.	The list of parameters here is large – the optimization here for each experiment is very specific.  IN GENERAL, the read libraries will need some trimming (to get rid of erroneous bases), but depending on the quality of the data and the objective of the experiment more tailoring might be needed.  Go to “Trim n bases from high-quality…”  This is 5’ trimming, and it is necessary to trim the first 6 bases due to the barcode that is ligated prior to sequencing.

7.	Next go to “trim n bases from low-quality…” this is 3’ trimming and is dependent on the results of the FastQC analysis.  All base positions should have a mean quality score of >30.

8.	Run the mapping to obtain a .sam file

NGS: SAMTOOLS and Text manipulations 
1.	Here choose Filter Sam, select .sam file.  This file contains both mapped and unmapped reads.  Click “Add new Flag”.  Choose “The read is unmapped”.  Select Execute.  This will remove all unmapped reads.

2.	Interval files are the easiest for manipulating with perl. To change to an interval file use SamTools “sam to interval” function.


3.	The reads file must be sorted by the start position of each read. Do this using the sort function in galaxy. Sort on column #2. Choose ascending numerical sort.

4.	The file is now ready to be downloaded.

Linux Manipulations
1.	Using Nomachine client, log in to a virtual linux machine at MSI. Visit msi.umn.edu for more details.

2.	Use the function
 
%  ssh lab  

3.	Move to the desired directory:

%  cd Documents/desiredDirectory

4.	Download files:

%  firefox

      Use browser to go to galaxy.umn.edu and download interval files.
 
5.	To count the reads that align to coding sequences, a gff file is needed containing only CDS’s. Gff files can be downloaded from the NCBI ftp server. ftp://ftp.ncbi.nlm.nih.gov/genomes/Bacteria/

6.	 Take the gff file and run the extractcds.pl script:

%  perl extractcds.pl file.gff > newfile.gff

7.	Run ct_new.pl using the reads files and the .gff file.

%  perl ct_new.pl newfile.gff readfile.int > counts.txt

8.	Run the count script on the control and treatment sample. The last few lines that add up all of the total align reads need to be removed from these files. This can be done using the awk or head commands or by using a simple text editor (or excel).

9.	Use the join command to join the control and treatment files. 

%  join -1 1 -2 1 -o 1.1,1.2,1.3,1.4,1.5,1.6,2.1,2.2,2.3,2.4,2.5,2.6 -e "N" control.counts.txt treatment.counts.txt > joined.counts.txt

Using a text editor (or excel) edit the first line of the file such that the first column has a head of “GeneID”.

10.	 Use filezilla or winSCP to move counts.txt files from MSI machine to local machine. 

11.	 Open R and install edgeR package:

>source("http://bioconductor.org/biocLite.R")
>biocLite("edgeR")

12.	 Read counts file into edgeR:

       > x <- read.delim("counts.txt", row.names="GeneID")

13.	Set groups to indicate which columns are the read counts:

>  group <- factor(c(1,2)) ;if read counts are in column 1 and 2. The “GeneID” column does not count as a column in this case. If there are replicates, it would be something like 1,1,2,2 if the first two columns were replicates of 1 sample and the next two columns were reps of a different sample.

14.	Use the DGElist command:
       > y <- DGEList(counts=x, group=group)

15.	Calculate dispersions:

y <- estimateCommonDisp(y)
y <- estimateTagwiseDisp(y)
y <- calcNormFactors(y)

16.	Execute statistical test, in this case the Fischer exact test:

> et <- exactTest(y)

It is possible here to supply an estimate for the dispersion, if, for example, there are no replicates. Do this with the “dispersion” parameter: 

> et <- exactTest(y, dispersion=.3)

17.	Use the topTags command to calculate the false discovery rate. This adjusts the P-value for testing thousands of genes.

     > write.table(topTags(et, n=5000), file="resuls.txt", row.names=TRUE, col.names=TRUE,     sep="\t")

Be certain to set n greater than total number of genes in the .gff file if all data for all genes are desired.


