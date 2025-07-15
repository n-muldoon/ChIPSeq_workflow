#!/usr/bin/env nextflow

process REMOVE {
    label 'process_medium'
    container 'ghcr.io/bf528/bedtools:latest'

    input:
    tuple val(meta), path(repr_peaks)
    path(black)

    output:
    tuple val(meta), path('cleaned_peaks.bed'), emit: cleaned

    shell:
    """
    bedtools intersect -a $repr_peaks -b $black -v > cleaned_peaks.bed
    """
    //REMOVE(params.blacklist, INTERSECT.out.intersect)

    // Report those alignments that overlap NO genes. Like “grep -v”
    // bedtools intersect -a reads.bed -b genes.bed -v

    //name new fiile "cleaned_peaks.bed"
}
