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
		"""
		java -jar trimmomatic-0.39.jar \
			PE {input} \ # PE - indicates paired-end input
			{output} \
			ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:2:True \ # Cut Illumina adapters
			LEADING:3 \ # minimum quality required to keep a base in the beginning of the read
			TRAILING:3 \ # minimum quality required to keep a base in the end of the read
			MINLEN:36" # Drop reads with length below a threshold
		"""

rule map_reads:
	input:
		"{reads}_purified.fastq",
		"{genome}.fasta"
	output:
		"{genome}_{reads}.bam"
	shell:
		"BWA-MEM2"

rule mark_duplicated_reads:
	input:
	output:
	shell:
		"Picard tools"

rule filter_mapped_reads:
	input:
	output:
	shell:
		"KING"

rule call_SNP_Samtools:
	input:
		"{genome}_{reads}.bam"
	output:
	shell:
		"samtools"

rule call_SNP_BCFtools:
	input:
		"{genome}_{reads}.bam"
	output:
	shell:
		"bcftools"

rule call_SNP_GATK:
	input:
		"{genome}_{reads}.bam"
	output:
	shell:
		"GATK"
