#!/usr/bin/env nextflow

process SAMTOOLS_INDEX {
    label 'process_single'
    container 'ghcr.io/bf528/samtools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path(bam), path("*.bai"), emit: index

    shell:
    """
    samtools index --threads $task.cpus $bam
    """
}
