# workflow/rules/00_annotation.smk

rule filter_reference_gtf:
    input:
        raw_gtf = config["references"]["ref_gtf"]
    output:
        filtered_gtf = config["references"]["filtered_ref_gtf"]
    shell:
        """
        # Keep header lines (starting with #) OR lines where Column 3 is a standard RNA-seq feature
        awk 'BEGIN {{FS="\\t"}} $1 ~ /^#/ || $3 ~ /^(gene|transcript|exon|CDS|5UTR|3UTR|start_codon|stop_codon)$/' {input.raw_gtf} > {output.filtered_gtf}
        """

rule liftoff_personalized_annotation:
    input:
        target_fasta = get_assembly_path,
        ref_fasta = config["references"]["ref_genome"],
        ref_gtf = config["references"]["filtered_ref_gtf"]
    output:
        target_gtf = "results/00_annotation/{strain}_personalized.gtf"
    log:
        "logs/liftoff/{strain}.log"
    threads: 8
    conda:
        "../envs/00_annotation.yaml"
    shell:
        """
        liftoff \
            -g {input.ref_gtf} \
            -o {output.target_gtf} \
            -dir results/00_annotation/temp_{wildcards.strain} \
            -sc 0.95 \
            {input.target_fasta} \
            {input.ref_fasta} \
            > {log} 2>&1
        """