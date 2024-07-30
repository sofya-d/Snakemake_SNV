rule purify_reads:
	input:
		# Trimmomatic works with gzip compressed FASTQ
		"{reads}_1.fastq.gz",
		"{reads}_2.fastq.gz"
	output:
		"{reads}_1_purified.fastq.gz",
		temp("{reads}_1_unpaired.fastq.gz"),
		"{reads}_2_purified.fastq.gz",
		temp("{reads}_2_unpaired.fastq.gz")
	shell:
		# Parameters from the "Quik Start" from README.md on GitHub are saved
		"java -jar trimmomatic-0.39.jar "
		"PE {input} " # PE - indicates paired-end input
		"{output} "
		"ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:2:True " # Cut Illumina adapters
		"LEADING:3 " # minimum quality required to keep a base in the beginning of the read
		"TRAILING:3 " # minimum quality required to keep a base in the end of the read
		"MINLEN:36" # Drop reads with length below a threshold

rule index_genome:
	input:
		"{genome}.fasta.gz"
	output:
		index_prefix = f"{path_to_index}/{wildcards.genome}"
		"{genome}.0123",
		"{genome}.amb",
		"{genome}.ann",
		"{genome}.bwt.2bit.64",
		"{genome}.pac"
	shell:
		"bwa-mem2 index "
		"-p {output.index_prefix} " # Genome index prefix
		"{input}"

rule map_reads:
	input:
		"{genome}" # Genome index prefix,
		"{reads}_1_purified.fastq.gz",
		"{reads}_2_purified.fastq.gz"
	output:
		"{genome}_{reads}.bam"
	shell:
		"bwa-mem2 mem "
		"{input} "
		"-t 8 " # Number of threads.
		"| "
		"samtools sort "
		"--template-coordinate " # Sort by template-coordinate.
		"--threads 8 "
		"-l 9 " # Compression level, 9 is the highest.
		"--output-fmt BAM "
		"-o {output} "
		"- "

rule mark_duplicated_reads:
	input: "{genome}_{reads}.bam"
	output: "{genome}_{reads}_marked_dupl.bam"
	shell:
		"java -jar picard.jar MarkDuplicatesWithMateCigar " # Identifies duplicate reads, accounting for mate CIGAR.
		"--INPUT {input} " # Input must be coordinate-sorted.
		"--METRICS_FILE {output} " # File to write duplication metrics to.
		"--OUTPUT {output}" # File with marked duplicate records.

rule call_SNP_BCFtools:
	input:
		"{genome}_{reads}.bam"
	output:
	shell:
		"bcftools"
