project="."

mkdir -p $project/workflow/rules
mkdir -p $project/workflow/envs
mkdir -p $project/workflow/scripts
mkdir -p $project/config
mkdir -p $project/data/raw
mkdir -p $project/data/references
mkdir -p $project/results/{01_qc,02_alignments_iso1,02_alignments_personalized}
mkdir -p $project/logs
mkdir -p $project/containers

touch $project/workflow/Snakefile
# The 5 Segment Rules
touch $project/workflow/rules/01_qc.smk
touch $project/workflow/rules/02_mapping.smk
touch $project/workflow/rules/03_alignment_metrics.smk
touch $project/workflow/rules/04_annotation.smk
touch $project/workflow/rules/05_quantification.smk

touch $project/workflow/envs/mapping.yaml
touch $project/workflow/scripts/compute_qv.py
touch $project/config/config.yaml
touch $project/config/master_control.tsv
touch $project/README.md
touch $project/.gitignore

echo "Project scaffold created at $project/"
