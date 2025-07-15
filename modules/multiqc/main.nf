#!/usr/bin/env nextflow

process MULTIQC {
    label 'process_low'
    //aggregates other things together, that's why only need 1 core
    container 'ghcr.io/bf528/multiqc:latest'
    publishDir params.outdir

    input:
    path('*')

    output:
    
    path('*.html'), emit: html

    shell:
    """
    multiqc . -f
    """
}
