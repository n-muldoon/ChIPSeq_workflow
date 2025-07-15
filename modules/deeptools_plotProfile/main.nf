#!/usr/bin/env nextflow

process PLOT_PROF {
    label 'process_medium'
    conda 'envs/deeptools_env.yml'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    path(mx)

    output:
    path('*')

    shell:
    """
    plotProfile -m $mx -out IP_Profiles.png
    """
    //only for the IP samples

    // Report those alignments that overlap NO genes. Like “grep -v”
    // bedtools intersect -a reads.bed -b genes.bed -v

    //name new fiile "cleaned_peaks.bed"
}
