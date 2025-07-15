#!/usr/bin/env nextflow

process SAMTOOLS_STATS {
    label 'process_single'
    container 'ghcr.io/bf528/samtools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(meta), path(bam)
    //tuple val(meta), path("${meta}.Aligned.out.bam"), emit: bam

    output:
    tuple val(meta), path("${meta}.flagstat"), emit: flagstat
    shell:
    
    """
    samtools flagstat -@ $task.cpus $bam > ${meta}.flagstat
    """
}
