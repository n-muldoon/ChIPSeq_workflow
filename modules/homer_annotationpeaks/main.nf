#!/usr/bin/env nextflow

process ANNOTATE {
    label 'process_low'
    conda 'envs/homer_env.yml'
    container 'ghcr.io/bf528/homer:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(meta), path(cleaned_bed)
    path(genome)
    path(gtf)

    output:
    path('annotated_peaks.txt')

    shell:
    """
    annotatePeaks.pl $cleaned_bed $genome -gtf $gtf > annotated_peaks.txt
    """
}
