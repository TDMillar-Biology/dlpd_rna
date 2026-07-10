rule star_index_ref:
    input:
        fasta = config["references"]["ref_genome"],
        gtf = config["references"]["filtered_ref_gtf"]
    output:
        # Outputting a directory is standard practice for STAR indices in Snakemake
        idx_dir = directory(f"{config['references']['ref_genome']} + _star_index")
    threads: config["star"]["threads"]
    conda:
        "../envs/02_mapping.yaml"
    log: "logs/star_index/ref.log"
    shell:
        """
        mkdir -p {output.idx_dir}
        STAR --runMode genomeGenerate \
             --runThreadN {threads} \
             --genomeDir {output.idx_dir} \
             --genomeFastaFiles {input.fasta} \
             --sjdbGTFfile {input.gtf} \
             --outTmpDir {output.idx_dir}/_STARtmp \
             2> {log}
        """

rule star_index_personalized:
    input:
        fasta = f"{config['references']['personalized_dir']}/{{strain}}.fasta",
        gtf = "results/00_annotation/{strain}_personalized.gtf"
    output:
        idx_dir = directory(f"{config['references']['personalized_dir']}/{{strain}}_star_index")
    threads: config["star"]["threads"]
    conda:
        "../envs/02_mapping.yaml"
    log: "logs/star_index/{strain}_pers.log"
    shell:
        """
        mkdir -p {output.idx_dir}
        STAR --runMode genomeGenerate \
             --runThreadN {threads} \
             --genomeDir {output.idx_dir} \
             --genomeFastaFiles {input.fasta} \
             --sjdbGTFfile {input.gtf} \
             --outTmpDir {output.idx_dir}/_STARtmp \
             2> {log}
        """

rule star_map_to_ref:
    input:
        fq1 = "results/qc/trimmed/{strain}_R1.trim.fastq.gz",
        fq2 = "results/qc/trimmed/{strain}_R2.trim.fastq.gz",
        index = config["references"]["ref_genome"] + "_star_index" # Assuming standard naming
    output:
        bam = "results/alignments_iso1/{strain}_iso1_Aligned.sortedByCoord.out.bam",
        log = "results/alignments_iso1/{strain}_iso1_Log.final.out"
    threads: config["star"]["threads"]
    conda: "../envs/02_mapping.yaml"
    log: "logs/star/{strain}_iso1.log"
    shell:
        """
        STAR --runThreadN {threads} \
             --genomeDir {input.index} \
             --readFilesIn {input.fq1} {input.fq2} \
             --readFilesCommand zcat \
             --outFileNamePrefix results/alignments_iso1/{wildcards.strain}_iso1_ \
             --outSAMtype BAM SortedByCoordinate \
             --outSAMattributes NH HI AS nM MD 2> {log}
        """

rule star_map_to_personalized:
    input:
        fq1 = "results/qc/trimmed/{strain}_R1.trim.fastq.gz",
        fq2 = "results/qc/trimmed/{strain}_R2.trim.fastq.gz",
        # Dynamically point to the specific strain's genome index
        index = lambda wildcards: f"{config['references']['personalized_dir']}/{wildcards.strain}_star_index"
    output:
        bam = "results/alignments_personalized/{strain}_pers_Aligned.sortedByCoord.out.bam",
        log = "results/alignments_personalized/{strain}_pers_Log.final.out"
    threads: config["star"]["threads"]
    conda: "../envs/02_mapping.yaml"
    log: "logs/star/{strain}_pers.log"
    shell:
        """
        STAR --runThreadN {threads} \
             --genomeDir {input.index} \
             --readFilesIn {input.fq1} {input.fq2} \
             --readFilesCommand zcat \
             --outFileNamePrefix results/alignments_personalized/{wildcards.strain}_pers_ \
             --outSAMtype BAM SortedByCoordinate \
             --outSAMattributes NH HI AS nM MD 2> {log}
        """