#!/usr/bin/env nextflow

process PLOTCORR {
    label 'process_medium'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    //bigwig files
    path(bwsumm)
    val(cortype)

    output:
    path("${cortype}_plot.png")
    //a matrix containing the information from the bigWig files of all of your samples
    shell:
    """
    plotCorrelation -in $bwsumm -c $cortype -p heatmap -o ${cortype}_plot.png
    """
    //plotCorrelation -in matrix.gz -c spearman -p heatmap -o plot.png
}
