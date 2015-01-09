RNASeq
======

GALAXY: FASTQ GROOMER and FASTQC
1.	MSI usually directly loads these into Galaxy so no manual upload is needed.  These should be in fastq format.
2.	Under the NGS quality toolbox select fastq groomer and run it on each dataset.  Fastq Groomer changes the quality score format for use with Bowtie.
3.	Run FastQC (also in NGS quality toolbox) on each dataset.
4.	Record the quality across each base in the read.  Take not of which position at the 3’ end that the mean quality score falls off.  This is where you want to trim.

NGS MAPPING: Bowtie for Illumina
1.	Bowtie for Illumina requires 2 things – reads files (fastq) and a reference sequence (fasta).  It may be necessary to upload 2 reads files if a paired-end experiment was done.  
2.	At the top, select the reference sequence. To select an uploaded fasta sequence  choose “select from history”.
3.	Next select single-end or paired-end library.
4.	Next select reads files (fastq format)
5.	Next select “Full parameter list”
6.	The list of parameters here is large – the optimization here for each experiment is very specific.  IN GENERAL, the read libraries will need some trimming (to get rid of erroneous bases), but depending on the quality of the data and the objective of the experiment more tailoring might be needed.  Go to “Trim n bases from high-quality…”  This is 5’ trimming, and it is necessary to trim the first 6 bases due to the barcode that is ligated prior to sequencing.
7.	Next go to “trim n bases from low-quality…” this is 3’ trimming and is dependent on the results of the FastQC analysis.  All base positions should have a mean quality score of >30.
8.	Run the mapping to obtain a .sam file

NGS: SAMTOOLS and Text manipulations 
1.	Here choose Filter Sam, select .sam file.  This file contains both mapped and unmapped reads.  Click “Add new Flag”.  Choose “The read is unmapped”.  Select Execute.  This will remove all unmapped reads.
2.	Interval files are the easiest for manipulating with perl. To change to an interval file use SamTools “sam to interval” function.
3.	The reads file must be sorted by the start position of each read. Do this using the sort function in galaxy. Sort on column #2. Choose ascending numerical sort.
4.	The file is now ready to be downloaded.

Linux Manipulations
1.	In Itasca (linux cluster) run firefox and download data from Galaxy.
2.	To count the reads that align to coding sequences, a gff file is needed containing only CDS’s. Gff files can be downloaded from the NCBI ftp server. Take the gff file and run the extractcds.pl script.
a.	perl extractcds.pl file.gff > newfile.gff
3.	Run ct_new.pl using the reads files and the .gff file.
a.	perl ct_new.pl cds.gff readfile > counts.txt
