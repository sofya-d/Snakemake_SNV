rule purify_reads:
	input:
		"{reads}.fastq"
	output:
		"{reads}_purified.fastq"
	shell:
		"trimmomatic"

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
