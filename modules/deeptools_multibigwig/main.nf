#!/usr/bin/env nextflow

process MULTIBIGWIG {
    label 'process_medium'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    //bigwig files
    path(bigwig)

    output:
    path('bw_all.npz'), emit: multibwsummary
    //a matrix containing the information from the bigWig files of all of your samples
    shell:
    """
    multiBigwigSummary bins -b  ${bigwig.join(' ')} --labels ${bigwig.baseName.join(' ')} -o bw_all.npz -p $task.cpus
    """
    //multiBigwigSummary bins -b  ${bigwig.join(' ')} --labels ${bigwig.baseName.join(' ')} -o bw_all.npz -p $task.cpus
    //echo $bigwig
    //multiBigwigSummary bins -b  INPUT_rep2.bw --labels  -o bw_all.npz -p 8
}
