#!/usr/bin/env nextflow

process FIND_MOTIFS {
    label 'process_low'
    conda 'envs/homer_env.yml'
    container 'ghcr.io/bf528/homer:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(meta), path(cleaned_bed) // repr_filtered_peaks
    path(genome)

    output:
    path('motifs/')

    shell:
    """
    findMotifsGenome.pl $cleaned_bed $genome ./motifs -size 200 -mask
    """
    // findMotifsGenome.pl <peak/BED file> <genome> <output directory> -size # [options]
}
