rule fastp:
    input:
        fq1 = lambda wildcards: samples_df.loc[wildcards.strain, "fq1"],
        fq2 = lambda wildcards: samples_df.loc[wildcards.strain, "fq2"]
    output:
        fq1 = "results/qc/trimmed/{strain}_R1.trim.fastq.gz",
        fq2 = "results/qc/trimmed/{strain}_R2.trim.fastq.gz",
        html = "results/qc/fastp/{strain}_fastp.html",
        json = "results/qc/fastp/{strain}_fastp.json"
    threads: config["fastp"]["threads"]
    conda: "../envs/01_qc.yaml"
    log: "logs/fastp/{strain}.log"
    shell:
        """
        fastp -i {input.fq1} -I {input.fq2} \
              -o {output.fq1} -O {output.fq2} \
              -h {output.html} -j {output.json} \
              -w {threads} 2> {log}
        """

rule multiqc:
    input:
        expand("results/qc/fastp/{strain}_fastp.json", strain=STRAINS)
    output:
        "results/qc/multiqc_report.html"
    conda: "../envs/01_qc.yaml"
    log: "logs/multiqc.log"
    shell:
        """
        multiqc results/qc/fastp/ -o results/qc/ 2> {log}
        """