#!/usr/bin/env nextflow

process FASTQC {
    label 'process_low'
    container 'ghcr.io/bf528/fastqc:latest'
    publishDir params.outdir

    input:
    tuple val(name),path(fq)

    output:
    path('*.zip'), emit: zip
    path('*.html'), emit: html

    shell:
    """
    fastqc $fq -t $task.cpus
    """
    //paired-end
    //fastqc $fq -t $task.cpus
}
