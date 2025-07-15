#!/usr/bin/env nextflow

process INTERSECT {
    label 'process_medium'
    container 'ghcr.io/bf528/bedtools:latest'

    input:
    tuple val(meta), path(beda), path(bedb)

    output:
    tuple val(meta), path('repr_peaks.bed'), emit: intersect

    shell:
    """
    bedtools intersect -a $beda -b $bedb -f 0.5 -r > repr_peaks.bed
    """
    //

    //-a/-b: 	BAM/BED/GFF/VCF file 
    //-f	    Minimum overlap required as a fraction of A. Default is 1E-9 (i.e. 1bp)
    //-r	    Require that the fraction of overlap be reciprocal for A and B. 
    //          In other words, if -f is 0.90 and -r is used, this requires that B 
    //          overlap at least 90% of A and that A also overlaps at least 90% of B.
}
